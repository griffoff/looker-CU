view: late_activators {
  derived_table: {
    create_process: {
      sql_step:
        USE SCHEMA looker_scratch
      ;;
      sql_step:
        CREATE OR REPLACE TEMPORARY TABLE latest_cu_redemptions as
        --get latest redemption per guid
        with latest_redemp as(
          SELECT
          subevent.user_sso_guid
          ,guids.primary_guid
          ,COALESCE(guids.primary_guid, subevent.user_sso_guid) AS merged_guid
          ,subevent.contract_id
          ,subevent.user_environment
          ,subevent.platform_environment
          ,subevent._ldts
          ,subevent.local_time
          ,subevent.subscription_state
          ,subevent.subscription_start
          ,subevent.subscription_end
          ,TO_DATE(subevent.subscription_start) as SUBSCRIPTION_START_DT
          ,TO_DATE(subevent.subscription_end) as SUBSCRIPTION_END_DT
          ,DATEDIFF(d,subevent.local_time, subevent.subscription_end) as SUBSCRIPTION_DAYS
          ,row_number() over(partition by merged_guid order by local_time desc) as subscription_recency
          ,date_trunc('DAY', local_time)::date as local_date
          ,date.season_fiscal_year as subscrip_season_fiscal_year
          FROM PROD.UNLIMITED.RAW_SUBSCRIPTION_EVENT subevent
          LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid guids        ON   subevent.user_sso_guid = guids.partner_guid
          LEFT JOIN strategy.dw.dm_date_dimension_season date             ON   date_trunc('DAY', local_time)::date = date.calendar_date  --conversion needed to bring to YYYY-MM-DD format, otherwise misses on the join
          WHERE
          subevent.subscription_state in ('full_access')
          AND  subevent.user_environment = 'production'
          AND subevent.platform_environment = 'production'
          AND subevent._ldts >= to_date('01-Aug-2018')
          --remove excluded users
          AND NOT
            (
              EXISTS(
                SELECT 1 FROM PROD.UNLIMITED.EXCLUDED_USERS excluded LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid guids_forexcl ON excluded.user_sso_guid = guids_forexcl.partner_guid
                     WHERE COALESCE(guids_forexcl.primary_guid, excluded.user_sso_guid) = COALESCE(guids.primary_guid, subevent.user_sso_guid)
              )
            )
          --filter out redemption transactions associated with extra transactions from shadow guids
          AND NOT
            (
              EXISTS(SELECT 1 FROM STRATEGY.spr_review_fy19.offset_transactions offset_transactions WHERE offset_transactions.contract_id = subevent.contract_id)
               AND
              (subevent._LDTS >= TO_DATE('16-Dec-2018') AND subevent._LDTS < TO_DATE('01-Jan-2019') )
              AND subevent.subscription_state in ('full_access')
            )
        )
        --join to get latest redemption with a flag as to whether it is cui, multi-term activation
        select latest_redemp.*
        from latest_redemp
        where subscription_recency = 1
      ;;
      sql_step:
        ---------------------------------------------
        create or replace temporary table cu_course_actv as
        --create list of duplicate isbns where may have activated another course key
        with guid_isbn_multi as(
        --intention: pick up multi-term users (would have multiple same ISBN activations if show twice) and a-la-carte access code registrants (through ACT.ACTV_TRIAL_PURCHASE='Duplicate'). Should also pick up course retakes
        --note: could also bring in table non_dw_uploads.multi_term_credits from Tim Morley and see if had a registration date < activation date, but creates another dependency.
          SELECT
          COALESCE(primary_guid, user_guid) as merged_guid
          , actv_isbn
          ,count(*) as guid_isbn_multi_count
          FROM PROD.STG_CLTS.ACTIVATIONS_OLR ACT
          LEFT JOIN PROD.STG_CLTS.PRODUCTS PRODUCT ON ACT.actv_isbn = PRODUCT.isbn13  --must go left join or lose certain activation records like those with ISBN13 = '9780176745615'
          LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid guids        ON   act.user_guid = guids.partner_guid
          WHERE ACT.ACTV_DT > '01-Apr-2015'
          AND ACT.ACTV_USER_TYPE='student'
          AND ACT.PLATFORM<>'MindTap Reader'
          AND ACT.ACTV_TRIAL_PURCHASE<>'Trial'
          AND (DIVISION_CD <> 'CLU' OR DIVISION_CD IS NULL) --because some DIVISION_CD's are null, without including IS NULL clause, null DIVISION_CD rows will evaluate to UNKNOWN rather than TRUE, and will
          group by merged_guid, actv_isbn
        )
        ,cui_institutions as(
        select
          distinct institution_nm, deal_type, case when deal_type in ('Full School','All CL Courses') then 1 else 0 end as always_cui_redemp_flg
          --note: some schools are CUI only for certain departments, so some students at those schools may have CUI redemptions and others regular CU - shouldn't boot out in this case or message or will create confusing experience
          from STRATEGY.misc.cui_institutions_20190813
          where institution_nm not in ('TEXAS A&M UNIVERSITY SAN ANTONIO','LAKE LAND COLLEGE') --did not renew CU in FY20
        )
        --pull all potentially relevant activations
        ,activations as(
        SELECT
          COALESCE(guids.primary_guid, user_guid) AS merged_guid
          ,ACT.actv_dt
          ,act.actv_isbn
          ,act.platform
          ,ACT.context_id
          ,enroll.course_key
          ,enroll.course_name
          ,enroll.begin_date as course_begin_date
          ,enroll.end_date as course_end_date
          ,product.prod_family_cd
          ,product.prod_family_de
          ,product.pub_series_cd
          ,product.pub_series_de
          ,product.division_cd
          ,product.division_de
          ,ent.institution_nm
          ,redemp.local_date as redemp_local_date
          ,redemp.subscription_end_dt
          ,multi.guid_isbn_multi_count
          ,datediff('DAY',actv_dt,subscription_end_dt)  as actv_days_from_sub_end
          ,case when course_end_date > subscription_end_dt then 1 else 0 end as course_beyond_subscrip_flg
          ,case when guid_isbn_multi_count > 1 then 1 else 0 end as multi_flg
          ,case when cui.institution_nm is not null then 1 else 0 end as cui_flg
          ,case when cui_flg = 1 and cui.always_cui_redemp_flg = 1 then 1 else 0 end as always_cui_redemp_flg
          ,case when cui_flg = 1 and cui.always_cui_redemp_flg = 0 then 1 else 0 end as sometimes_cui_redemp_flg
          ,case when actv_days_from_sub_end >= 0 and actv_days_from_sub_end <= 30 then 1 else 0 end as late_actv_flg
          FROM PROD.STG_CLTS.ACTIVATIONS_OLR ACT
          LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid guids        ON   act.user_guid = guids.partner_guid
          LEFT join latest_cu_redemptions redemp on COALESCE(guids.primary_guid, user_guid) = redemp.merged_guid
          LEFT JOIN PROD.STG_CLTS.PRODUCTS PRODUCT ON ACT.actv_isbn = PRODUCT.isbn13  --must go left join or lose certain activation records like those with ISBN13 = '9780176745615'
          LEFT JOIN prod.stg_clts.olr_courses enroll ON ACT.context_id = enroll."#CONTEXT_ID"
          LEFT JOIN prod.stg_clts.entities ent ON ACT.entity_no = ent.entity_no                                                                           ---------------------------------PETE: BETTER SNOWFLAKE TABLE TO USE?
          LEFT JOIN guid_isbn_multi multi on COALESCE(guids.primary_guid, act.user_guid) = multi.merged_guid and act.actv_isbn = multi.actv_isbn
          LEFT JOIN cui_institutions cui on ent.institution_nm = cui.institution_nm
          WHERE ACT.ACTV_DT > '01-Aug-2018'
          AND ACT.ACTV_USER_TYPE='student'
          AND ACT.PLATFORM NOT IN ('MindTap Reader', 'Cengage Unlimited')
          AND ACT.ORGANIZATION='Higher Ed' --only removing higher ed users
          AND ACT.ACTV_TRIAL_PURCHASE<>'Trial'
          AND ACT.ACTV_TRIAL_PURCHASE<>'Duplicate'
          AND DIVISION_CD <> 'CLU'
          AND DIVISION_CD IS NOT NULL
          AND CU_FLG = 'Y'
        )
        select CURRENT_TIMESTAMP() AS _ldts
          , *
        from activations
      ;;
      sql_step:
        --get those eligible to message
        create or replace temporary table message_eligible as
        select * from cu_course_actv where late_actv_flg = 1 and cui_flg = 0 and multi_flg = 0 and course_beyond_subscrip_flg = 1
      ;;
      sql_step:
        --get those eligible to remove
        create or replace temporary table removal_eligible as
        select
        *, 'REMOVAL' as email_type, 'REM' as ipm_type
        from cu_course_actv where late_actv_flg = 1 and sometimes_cui_redemp_flg = 0 and multi_flg = 0 and course_beyond_subscrip_flg = 1
         ;;
      sql_step:
        --email one: late activators activating yesterday
        create or replace temporary table email_one as
        select
        * ,'EMAIL 1' as email_type, 'N/A' as ipm_type
        from message_eligible where actv_dt = current_date - 1
      ;;
      sql_step:
        --email two: on subscription end date
        create or replace temporary table email_two as
        select
        * ,'EMAIL 2' as message_type, 'N/A' as ipm_type
        from message_eligible where subscription_end_dt = current_date
      ;;
      sql_step:
        --IPM messages
        create or replace temporary table daily_ipm_info as
        select
        *, 'N/A' as message_type, 'IPM' as ipm_type
        from message_eligible where subscription_end_dt = current_date + 1
      ;;
    sql_step:
      --consolidate all tables
      create or replace table daily_messaging_info as
      select * from email_one
      --union all
      --select * from email_two
      union all
      select * from daily_ipm_info
      union all
      select * from removal_eligible
            ;;
    sql_step:
      ALTER TABLE daily_messaging_info ADD COLUMN promo_code STRING, lookup STRING
      ;;
    #sql_step:
    #  -- for testing, wipe out and start again
    #  --DROP TABLE IF EXISTS late_activators_promo_codes
    #  ;;
      sql_step:
      --create table to store user + promo_code mapping so that we don't assign the same one to multiple users, or multiple codes to the same user
      CREATE TABLE IF NOT EXISTS late_activators_promo_codes
      AS
      SELECT
        NULL::STRING AS user_sso_guid
        ,promo_code AS promo_code
      FROM strategy.late_activators.promo_codes
      ;;
    sql_step:
      MERGE INTO daily_messaging_info i
      USING late_activators_promo_codes p ON i.merged_guid = p.user_sso_guid
      WHEN MATCHED THEN UPDATE
        SET i.promo_code = p.promo_code
      ;;
    sql_step:
      MERGE INTO daily_messaging_info a
        USING (
            SELECT user_sso_guid, promo_code
            FROM (
                SELECT user_sso_guid, dense_rank() OVER (ORDER BY RANDOM(1)) as id
                FROM (
                  SELECT DISTINCT merged_guid AS user_sso_guid
                  FROM daily_messaging_info
                  WHERE promo_code IS NULL
                )
              ) unassigned_users
            INNER JOIN (
              SELECT DISTINCT promo_code, dense_rank() OVER (ORDER BY RANDOM(1)) as id
              FROM late_activators_promo_codes
              WHERE user_sso_guid IS NULL
                ) unassigned_promo_codes ON unassigned_users.id = unassigned_promo_codes.id
          ) p ON a.merged_guid = p.user_sso_guid
        WHEN MATCHED THEN UPDATE
          SET promo_code = p.promo_code
    ;;
    sql_step:
      UPDATE daily_messaging_info
      SET lookup = HASH(merged_guid, email_type, ipm_type, course_key)
    ;;
    sql_step:
        MERGE INTO late_activators_promo_codes c
        USING (
          SELECT DISTINCT merged_guid, promo_code
          FROM daily_messaging_info
        ) p ON c.promo_code = p.promo_code
        WHEN MATCHED THEN UPDATE
          SET c.user_sso_guid = p.merged_guid
    ;;
    sql_step:
      CREATE TABLE IF NOT EXISTS late_activations_all_messages
      AS
      SELECT * FROM daily_messaging_info
      LIMIT 0
      ;;
    sql_step:
      INSERT INTO late_activations_all_messages
      SELECT *
      FROM daily_messaging_info
      WHERE lookup NOT IN (SELECT lookup FROM late_activations_all_messages)
      ;;
    sql_step:
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
      CLONE late_activations_all_messages
    ;;
    }

    sql_trigger_value: CURRENT_DATE() ;;
    #persist_for: "24 hours"
  }


  dimension: lookup {primary_key: yes hidden:yes}
  dimension: user_sso_guid { sql:${TABLE}.merged_guid;;}
  dimension: promo_code {}
  dimension: course_key {}
  dimension: activation_date {type:date sql:${TABLE}.actv_dt;;}
  dimension: subscription_end_date {type:date sql:${TABLE}.subscription_end_dt;;}
  dimension: email_msg_type{ type:string
      sql: ${TABLE}.email_type ;;
      #sql:COALESCE('EMAIL ' || ${TABLE}.email_msg_type::STRING, 'N/A');;
      }
  dimension: ipm_msg_type{ type:string
    sql: ${TABLE}.ipm_type ;;
    #sql:COALESCE('EMAIL ' || ${TABLE}.ipm_msg_type::STRING, 'N/A');;
    }
  dimension_group: _ldts {
    group_label: "Generated"
    label: "Generated"
    type: time
    timeframes: [raw, date]
  }
  dimension: course_name {
    label: "Course Name"
  }
  dimension: institution_nm {
    label: "Institution Name"
  }

  measure: count {
    label: "# Records"
    type: count
  }

  measure: user_count {
    label: "# Students"
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }

}
