# include: "ipm_campaign.view"

# view: ipm_campaign_dev {
# extends: [ipm_campaign]

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

#   dimension: message_body {
#     type: string
#     sql: ${TABLE}."MESSAGE_BODY" ;;
#   }

#   dimension: message_format_version {
#     type: string
#     sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
#   }

#   dimension: message_title {
#     type: string
#     sql: ${TABLE}."MESSAGE_TITLE" ;;
#   }

#   dimension: message_type {
#     type: string
#     sql: ${TABLE}."MESSAGE_TYPE" ;;
#   }

#   dimension: platform_environment {
#     type: string
#     sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
#   }

#   dimension: product_platform {
#     type: string
#     sql: ${TABLE}."PRODUCT_PLATFORM" ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: []
#   }

# }
