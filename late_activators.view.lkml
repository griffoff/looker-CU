view: late_activators {
  derived_table: {
    # need to add CUI and multi term
    create_process: {
      sql_step:
        -- for testing, wipe out and start again
        DROP TABLE IF EXISTS looker_scratch.late_activators;
      ;;
      sql_step:
        -- for testing, wipe out and start again
        DROP TABLE IF EXISTS looker_scratch.late_activators_promo_codes;
      ;;
      sql_step:
      --create table to store messages
        CREATE TABLE IF NOT EXISTS looker_scratch.late_activators (
          _ldts TIMESTAMP
          ,user_sso_guid STRING
          ,course_key STRING
          ,activation_date TIMESTAMP_TZ
          ,subscription_end_date TIMESTAMP_TZ
          ,promo_code STRING
          ,email_msg_type INT
          ,ipm_msg_type INT
          ,lookup STRING
        )
      ;;
      sql_step:
        --create table to store user + promo_code mapping so that we don't assign the same one to multiple users, or multiple codes to the same user
        CREATE TABLE IF NOT EXISTS looker_scratch.late_activators_promo_codes
        AS
        SELECT
          NULL::STRING AS user_sso_guid
          ,promo_code AS promo_code
        FROM strategy.late_activators.promo_codes
      ;;
      sql_step:
      --multi-term activations
        CREATE OR REPLACE TEMPORARY TABLE looker_scratch.multi_term
        AS
        SELECT
          COALESCE(primary_guid, user_guid) as merged_guid
          ,actv_isbn
          ,count(*) as guid_isbn_multi_count
        FROM PROD.STG_CLTS.ACTIVATIONS_OLR ACT
        LEFT JOIN PROD.STG_CLTS.PRODUCTS PRODUCT ON ACT.actv_isbn = PRODUCT.isbn13  --must go left join or lose certain activation records like those with ISBN13 = '9780176745615'
        LEFT JOIN prod.unlimited.vw_partner_to_primary_user_guid guids        ON   act.user_guid = guids.partner_guid
        WHERE ACT.ACTV_DT > '01-Apr-2015'
        AND ACT.ACTV_USER_TYPE='student'
        AND ACT.PLATFORM<>'MindTap Reader'
        AND ACT.ACTV_TRIAL_PURCHASE<>'Trial'
        AND (DIVISION_CD <> 'CLU' OR DIVISION_CD IS NULL)
        GROUP BY 1, 2
        HAVING COUNT(*) > 1
      ;;
      sql_step:
        --get all users who fit the 30 day late activation criteria and write them to the messages table
        INSERT INTO looker_scratch.late_activators
        SELECT
          current_timestamp()
          ,user_courses.user_sso_guid
          ,user_courses.olr_course_key AS course_key
          ,user_courses.activation_date
          ,learner_profile.subscription_end AS subscription_end_date
          ,NULL AS promo_code
          ,CASE
            WHEN DATEDIFF(DAY, activation_date::DATE, CURRENT_DATE()) BETWEEN 0 AND 2
            THEN 1 --first message, soon after activation
            --not allowed to send 2nd message
            --WHEN DATEDIFF(DAY, CURRENT_DATE(), subscription_end_date::DATE) = 7
            --THEN 2 --message 7 days before access is removed (subscription end date)
            WHEN CURRENT_DATE() = subscription_end_date::DATE
            THEN 3
            END AS email_msg_type
           ,CASE
              WHEN DATEDIFF(DAY, CURRENT_DATE(), subscription_end_date::DATE) = 1
              THEN 1
            END AS ipm_msg_type
          ,HASH(user_courses.user_sso_guid, activation_date, course_key, email_msg_type, ipm_msg_type) as lookup
         FROM ${user_courses.SQL_TABLE_NAME} user_courses
        LEFT JOIN (
              SELECT actv_code, actv_isbn, ROW_NUMBER() OVER (PARTITION BY actv_code ORDER BY ldts DESC) = 1 as latest
              FROM prod.stg_clts.activations_olr WHERE in_actv_flg = 1
              ) a ON user_courses.activation_code = a.actv_code AND a.latest
        INNER JOIN ${learner_profile.SQL_TABLE_NAME} learner_profile ON user_courses.user_sso_guid = learner_profile.user_sso_guid
        LEFT JOIN looker_scratch.multi_term ON user_courses.user_sso_guid = multi_term.merged_guid
                          AND a.actv_isbn = multi_term.actv_isbn
        WHERE learner_profile.subscription_status = 'Full Access'
        AND multi_term.merged_guid IS NULL --exclude multi term activations
        AND user_courses.activation_date IS NOT NULL
        AND user_courses.activation_date >= DATEADD(DAY, -30, subscription_end_date)
        AND user_courses.course_end_date > subscription_end_date
        --exclude people who have already been picked up for a given message
        AND lookup NOT IN (SELECT lookup FROM looker_scratch.late_activators)
        AND (ipm_msg_type IS NOT NULL OR email_msg_type IS NOT NULL)

        ;;
      sql_step:
       MERGE INTO looker_scratch.late_activators a
        USING (
            SELECT user_sso_guid, promo_code
            FROM (
                SELECT user_sso_guid, dense_rank() OVER (ORDER BY RANDOM(1)) as id
                FROM (
                  SELECT DISTINCT user_sso_guid
                  FROM looker_scratch.late_activators
                  WHERE promo_code IS NULL
                )
              ) unassigned_users
            INNER JOIN (
              SELECT DISTINCT promo_code, dense_rank() OVER (ORDER BY RANDOM(1)) as id
              FROM looker_scratch.late_activators_promo_codes
              WHERE user_sso_guid IS NULL
                ) unassigned_promo_codes ON unassigned_users.id = unassigned_promo_codes.id
          ) p ON a.user_sso_guid = p.user_sso_guid
        WHEN MATCHED THEN UPDATE
          SET promo_code = p.promo_code
      ;;
      sql_step:
        INSERT INTO looker_scratch.late_activators_promo_codes
        SELECT DISTINCT user_sso_guid, promo_code
        FROM looker_scratch.late_activators
        WHERE user_sso_guid NOT IN (SELECT user_sso_guid FROM looker_scratch.late_activators_promo_codes)
      ;;
      sql_step:
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME}
      CLONE looker_scratch.late_activators;;
    }

    datagroup_trigger: daily_refresh
  }

  dimension: lookup {primary_key: yes hidden:yes}
  dimension: user_sso_guid {}
  dimension: promo_code {}
  dimension: course_key {}
  dimension: activation_date {type:date}
  dimension: subscription_end_date {type:date}
  dimension: email_msg_type{ type:string sql:COALESCE(${TABLE}.email_msg_type::STRING, 'N/A');;}
  dimension: ipm_msg_type{ type:string sql:COALESCE(${TABLE}.ipm_msg_type::STRING, 'N/A');;}
  dimension_group: _ldts {
    group_label: "Generated"
    label: "Generated"
    type: time
    timeframes: [raw, date]
  }

}
