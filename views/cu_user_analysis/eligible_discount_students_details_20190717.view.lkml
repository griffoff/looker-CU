explore:  eligible_discount_students_details_20190717 {}

view: eligible_discount_students_details_20190717 {
  derived_table: {
    sql:  WITH discount_info AS
  (
  SELECT
      di.user_sso_guid
      ,di.api_call_time
      ,d.value:isbn AS isbn
      ,d.value:codeType AS code_type
      ,d.value:discount AS discount
      ,d.index
      ,di.price_details
--      ,di.price_details:"calculationentries"[0]:"calculationDate" AS calculation_date
  FROM dev.discount_email_campaign_fall2020.discount_info_collection_20190717_01 di
  FULL JOIN LATERAL FLATTEN(price_details:"discounts", outer => True) d
  --WHERE user_sso_guid IN ('eeff5268e40828a1:-c07473c:1685df4642a:-77f3','95096707cdeb01a5:-6f9b3e57:15e3ed2eb93:75a3', 'a15ddf83fa099d8d:566a5b0f:165a288a800:-6a0c',  'c69946bd2c15601a:-1b2b352f:16852150397:1440', 'ae638e442711a04b:7c94f27a:16586d6f77d:-7a0b')
  )
--GRANT SELECT ON TABLE dev.discount_email_campaign_fall2020.eligible_discount_students_details TO ROLE looker_prod;
--SELECT * FROM discount_info WHERE discount IS NOT NULL;
--  SELECT * FROM discount_info LIMIT 20;
  --SELECT * FROM discount_info WHERE isbn IS NULL LIMIT 200;
  -- Joins above discount info table to list of filtered students that was input for DPS script
  -- Also then joins activations to pick up activation date, activation code, activation isbn, and cu flag
  ,student_criteria_and_discount AS (
    SELECT
        s.user_guid
        ,s.most_recent_platform_activation
        ,s.most_recent_activation_code
        ,s.most_recent_activation_date
        ,s.subscription_state
        ,s.subscription_end
        ,di.*
        ,a.actv_dt
        ,a.actv_code
        ,a.cu_flg
        ,a.actv_isbn
    FROM dev.discount_email_campaign_fall2020.students_email_campaign_criteria_20190717_01 s
    LEFT JOIN discount_info di
        ON s.user_guid = di.user_sso_guid
    LEFT JOIN prod.stg_clts.activations_olr a
    ON di.user_sso_guid = a.user_guid
    AND isbn = a.actv_isbn
   )
--   SELECT * FROM student_criteria_and_discount;
--   SELECT * FROM student_criteria_and_discount LIMIT 1000;
   -- Filter out activation dates that are between 26 and 30 days ago in calculating amount to upgrade
   --Aggregates by student discounts and other related info
   -- Filters out all students with no cu discount eligible activations
   ,activations AS (
   SELECT
      DATEDIFF(d, actv_dt, CURRENT_DATE()) AS days_since_activated
        ,CASE WHEN days_since_activated < 25 THEN 1 ELSE 0 END AS activated_past_25
        ,CASE WHEN days_since_activated BETWEEN 26 AND 30 THEN 1 ELSE 0 END AS activated_26_30
        ,*
   FROM student_criteria_and_discount
   )
--   SELECT * FROM activations;
   ,user_activations AS (
        SELECT
            user_guid
            ,SUM(activated_past_25) AS activated_past_25_total
            ,SUM(activated_26_30) AS activated_26_30_total
            ,MAX(most_recent_platform_activation) AS most_recent_platform_activation
            ,MAX(most_recent_activation_code) AS oldest_activation_code
            ,MIN(actv_dt) AS earliest_activation_date
            ,MAX(actv_dt) AS oldest_activation_date
            ,COUNT(DISTINCT actv_dt) AS number_activation_dates
        FROM activations
        GROUP BY 1
    )
--    SELECT * FROM user_activations;
--    SELECT
--      COUNT(*)
--      ,COUNT(DISTINCT user_guid) AS unique_users
--      ,COUNT(CASE WHEN activated_past_25_total > 0 THEN 1 END) AS activation_in_past_25_days
--      ,COUNT(CASE WHEN activated_past_25_total > 0 AND activated_26_30_total > 0 THEN 1 END) AS activation_in_both
--    FROM user_activations  ;
   ,eligible_student_criteria_and_discount AS (
    SELECT
        user_sso_guid
        ,MAX(subscription_state) AS subscription_state
        ,MAX(subscription_end) AS subscription_end
        ,MAX(api_call_time) AS api_call_time
        ,ARRAY_SIZE(ARRAY_AGG(isbn)) AS number_of_discounts
        ,SUM(discount) AS discount_total
        ,CASE WHEN discount_total >= 119.99 THEN 0 ELSE (119.99 - discount_total) END AS amount_to_upgrade
        ,ARRAY_AGG(isbn) AS discounted_isbn_list
        ,ARRAY_AGG(code_type) AS code_type_list
        ,ARRAY_AGG(discount) AS discounts_list
--        ,MAX(calculation_date) AS calculation_date
        ,MAX(most_recent_platform_activation) AS most_recent_platform_activation
        ,MAX(most_recent_activation_code) AS most_recent_activation_code
        ,MAX(most_recent_activation_date) AS most_recent_activation_date
        ,MAX(actv_dt) AS activation_date
        ,MAX(actv_code) AS activation_code
        ,MAX(cu_flg) AS CU_subscription
    FROM student_criteria_and_discount
    WHERE isbn IS NOT NULL
    GROUP BY user_sso_guid
  )
  SELECT * FROM eligible_student_criteria_and_discount
  ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    hidden: yes
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
    primary_key: yes
    hidden: yes
  }

  dimension_group: api_call_time {
    group_label: "Discount Info"
    label: "Last updated"
    type: time
   timeframes: [date]
    sql: ${TABLE}."API_CALL_TIME" ;;
    hidden: no
  }

  dimension: discounted_isbn_list {
    group_label: "Discount Info"
    label: "ISBN producing discount"
    type: string
    sql: ${TABLE}."DISCOUNT_ISBN_LIST" ;;
  }

  dimension: code_type_list {
    group_label: "Discount Info"
    type: string
    sql: ${TABLE}."CODE_TYPE_LIST" ;;
  }

  dimension: discount_list {
    group_label: "Discount Info"
    type: number
    sql: COALESCE( ${TABLE}."DISCOUNT_LIST", 0)::float ;;
    value_format_name: usd
  }

  dimension: discount {
    group_label: "Discount Info"
    type: number
    sql: COALESCE( ${TABLE}."DISCOUNT_TOTAL", 0)::float ;;
    value_format_name: usd
  }

  dimension: amount_to_upgrade {
    group_label: "Discount Info"
    label: "Upgrade amount"
    description: "Amount to upgrade to one term Cengage Unlimited subscription"
    type: number
    sql:  CASE WHEN ((120 - ${discount}) < 0) THEN 0 ELSE (120 - ${discount}) END;;
    value_format_name: usd
  }



  dimension: most_recent_platform_activation {
    group_label: "Discount Info"
#     label: "most_recent_platform_activation"
    type: string
    sql: ${TABLE}."MOST_RECENT_PLATFORM_ACTIVATION";;
  }

  dimension: most_recent_activation_date {
    group_label: "Discount Info"
#     label: "most_recent_platform_activation"
    type: date
    sql: ${TABLE}."MOST_RECENT_ACTIVATION_DATE"::date;;
  }


  dimension: amount_to_upgrade_string {
    group_label: "Discount Info"
    label: "Upgrade amount string"
    description: "Amount to upgrade to one term Cengage Unlimited subscription"
    type: string
    sql: CASE WHEN ${amount_to_upgrade} <= 0 THEN "Free upgrade!" ELSE ${amount_to_upgrade}::STRING ;;
    hidden: yes
  }

  dimension: has_discount {
    group_label: "Discount Info"
    label: "Has a discount "
    type: yesno
    sql:  ${amount_to_upgrade} < 120;;
    value_format_name: usd
  }



  dimension: index {
    type: number
    sql: ${TABLE}."INDEX" ;;
    hidden:  yes
  }

  dimension: price_details {
    type: string
    sql: ${TABLE}."PRICE_DETAILS" ;;
    hidden:  yes
  }

  set: detail {
    fields: [
      user_sso_guid,
      api_call_time_date,
      discount,
      index,
      price_details
    ]
  }
}
