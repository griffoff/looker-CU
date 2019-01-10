view: cu_ebook_rollup {
  derived_table: {
    sql: WITH
      -- table of dates for use in filtering/reporting
      dates AS (
          SELECT
              GOVERNMENTDEFINEDACADEMICTERM as academic_term
              ,calendarmonthname
              ,datevalue
          FROM dw_ga.dim_date
          WHERE academic_term = 'Fall 2019'
      )
      -- generate a list of months to be included in the report
      ,months AS (
          SELECT
              calendarmonthname
              ,MIN(datevalue)::TIMESTAMP_NTZ AS month_start
              ,MAX(datevalue)::TIMESTAMP_NTZ AS month_end
          FROM dates
          GROUP BY 1
      )
      -- aggregate the cu ebook usage data by guid, isbn and subscription_state
      ,ebook_usage AS (
        SELECT
            u.user_sso_guid AS mapped_guid
            ,u.activity_date
            --,DATE_TRUNC('month', convert_timezone('America/New_York', u.activity_date)::timestamp_ntz) AS month
            ,DATE_TRUNC('month', u.activity_date::timestamp_ntz) AS month
            ,eisbn
            ,u.subscription_state
            ,SUM(decode(courseware, 'courseware', u.activity_count, 0)) AS activity_count_courseware
            ,SUM(decode(courseware, 'non-courseware', u.activity_count, 0)) AS activity_count_noncourseware
        --FROM unlimited.cu_ebook_usage u
        FROM prod.zpg.CU_EBOOK_USAGE_SRC_TMP u
        INNER JOIN dates d on u.activity_date::DATE = d.datevalue
      --  WHERE u.subscription_state in ('full_access', 'trial_access')
        GROUP BY 1, 2, 3, 4, 5
      )
      -- get subscriptions and map the shadow guids
      ,sub_status_detail
      AS (
       SELECT
           COALESCE(shadow.primary_guid, raw_data.user_sso_guid) AS MAPPED_GUID,
           SUBSCRIPTION_STATE,
           SUBSCRIPTION_START,
           SUBSCRIPTION_END
           ,LOCAL_TIME
           ,LEAD(SUBSCRIPTION_STATE) OVER (PARTITION BY MAPPED_GUID ORDER BY LOCAL_TIME, SUBSCRIPTION_START, SUBSCRIPTION_END) AS PREV_STATE
           ,LAG(LOCAL_TIME) OVER (PARTITION BY MAPPED_GUID ORDER BY LOCAL_TIME, SUBSCRIPTION_START, SUBSCRIPTION_END) AS PREV_TIME
           ,LEAD(LOCAL_TIME) OVER (PARTITION BY MAPPED_GUID ORDER BY LOCAL_TIME, SUBSCRIPTION_START, SUBSCRIPTION_END) AS NEXT_TIME
        FROM unlimited.raw_subscription_event AS raw_data
        LEFT JOIN UNLIMITED.SSO_MERGED_GUIDS AS shadow ON raw_data.user_sso_guid = shadow.SHADOW_GUID
        INNER JOIN dates d on raw_data.local_time::DATE = d.datevalue
        WHERE subscription_state in ('full_access', 'trial_access')
      )
      --filter duplicate subscription events
          -- more than 5 seconds after the previous event (or the first event) or the previous status is different
          -- the assumption is that the most recent record is the most accurate
      ,sub_status_base
      as (
        SELECT
          mapped_guid
          ,subscription_state
          ,MIN(local_time)::TIMESTAMP_NTZ AS effective_from_base
          ,MAX(subscription_end) as subscription_end
        FROM sub_status_detail
        WHERE (TIMEDIFF(second, prev_time, local_time) > 5
               OR prev_time IS NULL
               OR COALESCE(prev_state, subscription_state) != subscription_state)
        GROUP BY 1, 2
      )
      --create from and to dates for subscription statuses based on the next start date
      -- or the end date if there is no subsequent status
      -- to allow us to see who is in which state at any point in time
      ,sub_status
      as (
        SELECT
          *
          ,CASE WHEN LAG(effective_from_base) over (PARTITION BY mapped_guid ORDER BY effective_from_base) IS NOT NULL THEN effective_from_base END AS effective_from
          ,LEAD(effective_from_base) over (PARTITION BY mapped_guid ORDER BY effective_from_base) as effective_to
          ,COALESCE(effective_to, subscription_end)::TIMESTAMP_NTZ as effective_to_base
        FROM sub_status_base
      )
      -- join subscription statuses to months that those statuses were active
      -- then join it to ebook usage data for those months and statuses
      ,subs_usage AS (
        --assuming that the usage table is no of ebook actions, per day, per ebook, per user
        -- this counts the number of days where there is an activity for each user and ebook by month
        SELECT
            sub_status.mapped_guid
            --,DATE_TRUNC('month', convert_timezone('America/New_York', sub_status.effective_from_base)::timestamp_ntz) AS month
            ,months.month_start AS month
            ,sub_status.subscription_state
            ,usage.eisbn
            ,SUM(CASE WHEN usage.activity_count_courseware > 0 THEN 1 ELSE 0 END) AS days_opened_eisbn_courseware
            ,SUM(CASE WHEN usage.activity_count_noncourseware > 0 THEN 1 ELSE 0 END) AS days_opened_eisbn_noncourseware
        FROM  sub_status
        INNER JOIN months ON months.month_start BETWEEN DATE_TRUNC(MONTH, sub_status.effective_from_base) AND DATE_TRUNC(MONTH, sub_status.effective_to_base)
        LEFT JOIN ebook_usage usage
              ON usage.mapped_guid = sub_status.mapped_guid
      --        AND usage.subscription_state = sub_status.subscription_state
      --        AND months.month_start = usage.month
          AND (usage.activity_date::date >= sub_status.effective_from OR sub_status.effective_from IS NULL)
              AND (usage.activity_date::date <= sub_status.effective_to OR sub_status.effective_to IS NULL)
        --WHERE usage.activity_date IS NULL
        GROUP BY 1, 2, 3, 4
      )
      -- monthly ebook count per guid
      ,ebook_usage_guid_month AS
      (
        SELECT
          mapped_guid
          ,month
          ,subscription_state
          ,COUNT(DISTINCT CASE WHEN days_opened_eisbn_noncourseware > 1 THEN eisbn END) AS ebooks_opened_royalty
          ,COUNT(DISTINCT CASE WHEN days_opened_eisbn_noncourseware = 1 THEN eisbn END) AS ebooks_opened_non_royalty
          ,COUNT(DISTINCT CASE WHEN days_opened_eisbn_noncourseware >= 1 THEN eisbn END) AS ebooks_opened_non_courseware
          ,COUNT(DISTINCT CASE WHEN days_opened_eisbn_courseware >= 1 THEN eisbn END) AS ebooks_opened_courseware
          ,COUNT(DISTINCT eisbn) AS ebooks_opened_total
        FROM subs_usage
        --WHERE days_opened_eisbn > 1
        GROUP BY 1, 2, 3
      )
      --set guid = 'c5f4fc99e9fba1f8:5cac52cd:148febd55a6:-2a9e';
      --//select *
      --//from ebook_usage_guid_month_combined
      --//where mapped_guid = $guid
      --//;
      ,ebook_usage_guid_total AS (
        SELECT
          mapped_guid
          ,null AS month
          ,subscription_state
          ,MAX(ebooks_opened_royalty) AS ebooks_opened_royalty
          ,MAX(ebooks_opened_non_royalty) AS ebooks_opened_non_royalty
          ,MAX(ebooks_opened_courseware) AS ebooks_opened_courseware
          ,MAX(ebooks_opened_non_courseware) AS ebooks_opened_non_courseware
          ,MAX(ebooks_opened_total) AS ebooks_opened_total
          --use max for most in any month, sum for total overall
        FROM ebook_usage_guid_month
        GROUP BY 1, 2, 3
      )
      ,ebook_usage_output AS (
        SELECT
            mapped_guid
            ,month
            ,calendarmonthname
            ,subscription_state
            ,iff(subscription_state = 'trial_access', 1, 0) AS trial
            ,iff(subscription_state = 'full_access', 1, 0) AS full_access
            ,MAX(full_access) over (PARTITION BY mapped_guid) AS subscribed
            ,CASE WHEN ebooks_opened_royalty > 0 THEN 3 WHEN ebooks_opened_non_royalty > 0 THEN 2 WHEN ebooks_opened_courseware > 0 THEN 1 ELSE 0 END AS sort

            ,CASE
               WHEN ebooks_opened_total = 0 THEN 'No ebook usage activity'
               WHEN ebooks_opened_non_courseware = 0 THEN
                  CASE
                      WHEN ebooks_opened_courseware <= 2 THEN replace('Opened # Courseware eBooks (exclusively)', '#', ebooks_opened_courseware)
                      ELSE 'Opened 3+ Courseware eBooks (exclusively)'
                  END
               WHEN ebooks_opened_royalty = 0 THEN
                  CASE
                      WHEN ebooks_opened_non_royalty <= 2 THEN replace('Opened # non-Courseware eBooks (no royalty)', '#', ebooks_opened_non_royalty)
                      ELSE 'Opened 3+ non-Courseware eBooks (no royalty)'
                  END
               WHEN ebooks_opened_royalty <= 2 THEN replace('Opened # non-Courseware eBooks', '#', ebooks_opened_royalty)
               ELSE 'Opened 3+ non-Courseware eBooks'
             END AS ebook_usage_bucket

          ,CASE WHEN ebooks_opened_royalty > 0 THEN ebook_usage_bucket ELSE 'Opened 0 non-Courseware eBooks' END as ebook_royalty_bucket

          ,CASE
              WHEN ebooks_opened_total = 0 THEN ebook_usage_bucket
              WHEN ebooks_opened_non_courseware > 0 THEN
                  CASE
                      WHEN ebooks_opened_non_courseware <= 2 THEN replace('Opened # non-Courseware eBooks', '#', ebooks_opened_non_courseware)
                      ELSE 'Opened 3+ non-Courseware eBooks'
                  END
              ELSE 'Opened 0 non-Courseware eBooks'
              END as ebook_non_courseware_bucket
          ,CASE WHEN ebooks_opened_total > 0
                THEN mapped_guid END AS used_ebook
          ,CASE WHEN ebooks_opened_courseware > 0 AND ebooks_opened_non_courseware = 0
                THEN mapped_guid END AS used_courseware_ebook_only
          ,CASE WHEN trial * ebooks_opened_non_courseware > 0
                     AND full_access * ebooks_opened_non_courseware = 0
                THEN mapped_guid END AS used_noncourseware_ebook_trial_only
          ,CASE WHEN full_access * ebooks_opened_royalty = 0
                     AND full_access * ebooks_opened_non_royalty > 0
                THEN mapped_guid END AS used_noncourseware_ebook_no_royalty
          ,CASE WHEN full_access * ebooks_opened_royalty > 0
                THEN mapped_guid END AS used_noncourseware_ebook_royalty
        FROM  {% parameter table_name %} t
        LEFT JOIN dates d ON t.month = d.datevalue
        WHERE mapped_guid not in (select user_sso_guid from unlimited.excluded_users)
      )
      SELECT *
      FROM ebook_usage_output ;;
  }

  parameter: table_name {
    type: unquoted
    allowed_value: {
      label: "Monthly"
      value: "ebook_usage_guid_month"
    }
    allowed_value: {
      label: "Total"
      value: "ebook_usage_guid_total"
    }

  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: all_users {
    type: count_distinct
    sql: ${mapped_guid} ;;
    drill_fields: [detail*]
  }

  measure: sort_0 {
    type: min
    sql: ${month} ;;
  }

  measure: sort_1 {
    type: min
    sql: ${sort} ;;
  }

  measure: In_Trial_State_Everyone  {
    type: count_distinct
    sql: CASE WHEN trial = 1 THEN mapped_guid  END;;
  }

  measure: In_Trial_State_those_that_became_Full_access  {
    type: count_distinct
    sql: CASE WHEN trial = 1 AND subscribed = 1 THEN mapped_guid END;;
  }

  measure: In_Full_State  {
    type: count_distinct
    sql:CASE WHEN full_access = 1 THEN mapped_guid END;;
  }
  measure: Overall_of_those_that_eventually_paid  {
    type: count_distinct
    sql: CASE WHEN subscribed = 1 THEN mapped_guid END;;
  }
  measure: People_who_opene_up_at_least_one_ebook_one_or_more_times  {
    type: count_distinct
    sql: used_ebook;;
  }
  measure: People_who_used_only_courseware_related_ebooks  {
    type: count_distinct
    sql: used_courseware_ebook_only;;
  }
  measure: People_who_only_used_non_courseware_ebooks_while_in_trial_access  {
    type: count_distinct
    sql: used_noncourseware_ebook_trial_only;;
  }
  measure: People_who_only_used_non_courseware_ebooks_while_in_trial_access_but_not_enough_to_trigger_a_royalty  {
    type: count_distinct
    sql:used_noncourseware_ebook_no_royalty;;
  }
  measure:  People_who_only_used_non_courseware_ebooks_enough_to_potentially_trigger_a_royalty_event {
    type: count_distinct
    sql: used_noncourseware_ebook_royalty;;
  }


  dimension: mapped_guid {
    type: string
    sql: ${TABLE}."MAPPED_GUID" ;;
  }

  dimension: month {
    type: string
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: calendarmonthname {
    type: string
    sql: ${TABLE}."CALENDARMONTHNAME";;
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  }

  dimension: trial {
    type: number
    sql: ${TABLE}."TRIAL" ;;
  }

  dimension: full_access {
    type: number
    sql: ${TABLE}."FULL_ACCESS" ;;
  }

  dimension: subscribed {
    type: number
    sql: ${TABLE}."SUBSCRIBED" ;;
  }

  dimension: sort {
    type: number
    sql: ${TABLE}."SORT" ;;
  }

  dimension: ebook_usage_bucket {
    type: string
    sql: COALESCE(${TABLE}."EBOOK_USAGE_BUCKET", 'overall_bucket') ;;
  }

  dimension: ebook_royalty_bucket {
    type: string
#     sql: COALESCE(${TABLE}."EBOOK_ROYALTY_BUCKET", "TOTAL") ;;

    sql: ${TABLE}."EBOOK_ROYALTY_BUCKET" ;;
  }

  dimension: ebook_non_courseware_bucket {
    type: string
    sql: COALESCE(${TABLE}."EBOOK_NON_COURSEWARE_BUCKET", "overall_bucket") ;;
  }

  dimension: used_ebook {
    type: string
    sql: ${TABLE}."USED_EBOOK" ;;
  }

  dimension: used_courseware_ebook_only {
    type: string
    sql: ${TABLE}."USED_COURSEWARE_EBOOK_ONLY" ;;
  }

  dimension: used_noncourseware_ebook_trial_only {
    type: string
    sql: ${TABLE}."USED_NONCOURSEWARE_EBOOK_TRIAL_ONLY" ;;
  }

  dimension: used_noncourseware_ebook_no_royalty {
    type: string
    sql: ${TABLE}."USED_NONCOURSEWARE_EBOOK_NO_ROYALTY" ;;
  }

  dimension: used_noncourseware_ebook_royalty {
    type: string
    sql: ${TABLE}."USED_NONCOURSEWARE_EBOOK_ROYALTY" ;;
  }

  set: detail {
    fields: [
      mapped_guid,
      month,
      calendarmonthname,
      subscription_state,
      trial,
      full_access,
      subscribed,
      sort,
      ebook_usage_bucket,
      ebook_royalty_bucket,
      ebook_non_courseware_bucket,
      used_ebook,
      used_courseware_ebook_only,
      used_noncourseware_ebook_trial_only,
      used_noncourseware_ebook_no_royalty,
      used_noncourseware_ebook_royalty
    ]
  }
}
