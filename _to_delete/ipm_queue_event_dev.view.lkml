# include: "ipm_queue_event.view"

# view: ipm_queue_event_dev {
# extends: [ipm_queue_event]

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
#     hidden: yes
#   }

#   dimension: _rsrc {
#     type: string
#     sql: ${TABLE}."_RSRC" ;;
#     hidden: yes
#   }

#   dimension: batch_id {
#     type: string
#     sql: ${TABLE}."BATCH_ID" ;;
#   }

#   dimension: message_format_version {
#     type: string
#     sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
#   }

#   dimension: platform_environment {
#     type: string
#     sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
#   }

#   dimension: product_platform {
#     type: string
#     sql: ${TABLE}."PRODUCT_PLATFORM" ;;
#   }

#   dimension: user_environment {
#     type: string
#     sql: ${TABLE}."USER_ENVIRONMENT" ;;
#   }

#   }
