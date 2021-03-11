# view: raw_subscription_event_merged_2 {
#   derived_table: {
#     sql: with state AS (
#           SELECT
#               TO_CHAR(TO_DATE(raw_subscription_event_merged_2."SUBSCRIPTION_START" ), 'YYYY-MM-DD') AS sub_start_date
#               ,RANK () OVER (PARTITION BY mapped_guid ORDER BY LOCAL_Time DESC) AS latest_record
#               ,RANK () OVER (PARTITION BY mapped_guid ORDER BY LOCAL_Time ASC) AS earliest_record
#               ,LEAD(subscription_state) over(partition by mapped_guid order by local_time) as change_in_state
#               ,LEAD(subscription_start) over(partition by mapped_guid order by local_time) as change_in_start_date
#               ,*
#           FROM ZPG.RAW_SUBSCRIPTION_EVENT_MERGED_2
#           )

#           SELECT
#             state.*
#             ,CASE WHEN latest_record = 1 THEN 'yes' ELSE 'no' END AS latest_filter
#             ,CASE WHEN earliest_record = 1 THEN 'yes' ELSE 'no' END AS earliest_filter
#           FROM state
#           LEFT JOIN unlimited.excluded_users bk
#           ON state.mapped_guid = bk.user_sso_guid
#           WHERE bk.user_sso_guid IS NULL
#           ;;
#   }

#   dimension: latest_subscription {
#     label: "Current subscription record"
#     description: "filter used to retrive the latest subscription status for a user"
#     type: yesno
#     sql: ${TABLE}.latest_filter = 'yes'  ;;
#   }

#   dimension: earliest_subscription {
#     label: "Earliest subcription record"
#     description: "filter used to retrive the earliest subscription status for a user"
#     type: yesno
#     sql: ${TABLE}.earliest_filter = 'yes'  ;;
#   }

#   dimension: change_in_state {
#     label: "Subscription State Change"
#     description: "Displays what subscription state a user changed to."
#     sql: ${TABLE}.change_in_state ;;
#   }

#   dimension: change_in_start_date {
#     label: "Subscription Start Date Change"
#     description: "Displays the date that a user subscription state changed."
#     sql: ${TABLE}.change_in_start_date ;;
#     type: date
#   }

#   dimension: _hash {
#     type: string
#     sql: ${TABLE}."_HASH" ;;
#   }

#   dimension_group: _ldts {
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}."_LDTS" ;;
#   }

#   dimension: _rsrc {
#     type: string
#     sql: ${TABLE}."_RSRC" ;;
#   }

#   dimension: access_code {
#     type: string
#     sql: ${TABLE}."ACCESS_CODE" ;;
#   }

#   dimension: contract_id {
#     type: string
#     sql: ${TABLE}."CONTRACT_ID" ;;
#   }

#   dimension_group: local {
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}."LOCAL_TIME" ;;
#   }

#   dimension: mapped_guid {
#     type: string
#     sql: ${TABLE}."MAPPED_GUID" ;;
#   }

#   dimension: message_format_version {
#     type: string
#     sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
#   }

#   dimension: message_type {
#     type: string
#     sql: ${TABLE}."MESSAGE_TYPE" ;;
#   }

#   dimension: original_guid {
#     type: string
#     sql: ${TABLE}."ORIGINAL_GUID" ;;
#   }

#   dimension: platform_environment {
#     type: string
#     sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
#   }

#   dimension: product_platform {
#     type: string
#     sql: ${TABLE}."PRODUCT_PLATFORM" ;;
#   }

#   dimension_group: subscription_end {
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}."SUBSCRIPTION_END" ;;
#   }

#   dimension_group: subscription_start {
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: ${TABLE}."SUBSCRIPTION_START" ;;
#   }

#   dimension: subscription_state {
#     type: string
#     sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
#   }

#   dimension: transferred_contract {
#     type: string
#     sql: ${TABLE}."TRANSFERRED_CONTRACT" ;;
#   }

#   dimension: user_environment {
#     type: string
#     sql: ${TABLE}."USER_ENVIRONMENT" ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: []
#   }
# }
