# view: csat_survey {
#   derived_table: {
#     sql: Select COALESCE(shadow.primary_guid, c.guid) AS MAPPED_GUID,* from UPLOADS.CSAT_SURVEY.TMPQ c

#             LEFT JOIN UNLIMITED.VW_PARTNER_TO_PRIMARY_USER_GUID AS shadow ON c.guid = shadow.PARTNER_GUID
#             ;;
#   }

#   set: marketing_fields {fields:[question,platform,satisfaction_rating,content,ease_of_use]}

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   dimension: mapped_guid {
#     type: string
#     sql: ${TABLE}."MAPPED_GUID" ;;
#   }

#   dimension: _file {
#     type: string
#     sql: ${TABLE}."_FILE" ;;
#   }

#   dimension: _line {
#     type: number
#     sql: ${TABLE}."_LINE" ;;
#     hidden: yes
#   }

#   dimension: guid {
#     type: string
#     sql: ${TABLE}."GUID" ;;
#     hidden: yes
#   }

#   dimension: recorded_date {
#     type: string
#     sql: ${TABLE}."RECORDED_DATE" ;;
#   }

#   dimension: question {
#     type: string
#     sql: ${TABLE}."QUESTION" ;;
#   }

#   dimension: platform {
#     type: string
#     sql: ${TABLE}."PLATFORM" ;;
#   }

#   dimension: satisfaction_rating {
#     type: string
#     sql: ${TABLE}."SATISFACTION_RATING" ;;
#   }

#   dimension: can_you_tell_us_more_about_why_you_gave_this_rating_ {
#     type: string
#     sql: ${TABLE}."CAN_YOU_TELL_US_MORE_ABOUT_WHY_YOU_GAVE_THIS_RATING_" ;;
#   }

#   dimension: content {
#     type: string
#     sql: ${TABLE}."CONTENT" ;;
#   }

#   dimension: ease_of_use {
#     type: string
#     sql: ${TABLE}."EASE_OF_USE" ;;
#   }

#   dimension: technical {
#     type: string
#     sql: ${TABLE}."TECHNICAL" ;;
#   }

#   dimension: access {
#     type: string
#     sql: ${TABLE}."ACCESS" ;;
#   }

#   dimension: other {
#     type: string
#     sql: ${TABLE}."OTHER" ;;
#   }

#   dimension_group: _fivetran_synced {
#     type: time
#     sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
#     hidden: yes
#   }

#   dimension: partner_guid {
#     type: string
#     sql: ${TABLE}."PARTNER_GUID" ;;
#   }

#   dimension: primary_guid {
#     type: string
#     sql: ${TABLE}."PRIMARY_GUID" ;;
#   }

#   dimension_group: event_time {
#     type: time
#     sql: ${TABLE}."EVENT_TIME" ;;
#   }

#   set: detail {
#     fields: [
#       mapped_guid,
#       _file,
#       _line,
#       guid,
#       recorded_date,
#       question,
#       platform,
#       satisfaction_rating,
#       can_you_tell_us_more_about_why_you_gave_this_rating_,
#       content,
#       ease_of_use,
#       technical,
#       access,
#       other,
#       _fivetran_synced_time,
#       partner_guid,
#       primary_guid,
#       event_time_time
#     ]
#   }
# }
