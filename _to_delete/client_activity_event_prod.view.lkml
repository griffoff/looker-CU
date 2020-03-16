# explore: test_cae {from: client_activity_event_prod}
#
# view: client_activity_event_prod {
# #   sql_table_name: CAP_EVENTING.PROD.CLIENT_ACTIVITY_EVENT;;
# derived_table: {
#   sql: with
#         prim_map AS
#           (
#             SELECT *,LEAD(event_time) OVER (PARTITION BY primary_guid ORDER BY event_time ASC) IS NULL AS latest from prod.unlimited.VW_PARTNER_TO_PRIMARY_USER_GUID
#           )
#         ,cae AS
#         (
#           SELECT
#               event_id
#               ,COALESCE(user_environment, product_environment) AS platform_environment
#               ,_ldts
#               ,_rsrc
#               ,message_format_version
#               ,message_type
# --              , CONVERT_TIMEZONE('UTC', event_time) AS event_time
#               ,event_time
#               ,event_category
#               ,event_action
#               ,product_platform
#               ,session_id
#               ,user_sso_guid
#               ,event_uri
#               ,host_platform
#               ,tags
#               ,MAX(CASE WHEN s.value:key::string = 'courseKey' THEN s.value:value::string END) AS courseKey
#               ,MAX(CASE WHEN s.value:key::string = 'carouselName' THEN s.value:value::string END) AS carouselName
#               ,MAX(CASE WHEN s.value:key::string = 'carouselSessionId' THEN s.value:value::string END) AS carouselSessionId
#               ,MAX(CASE WHEN s.value:key::string = 'activityId' THEN s.value:value::string END) AS activityId
#               ,MAX(CASE WHEN s.value:key::string = 'checkpointId' THEN s.value:value::string END) AS checkpointId
#               ,MAX(CASE WHEN s.value:key::string = 'contentType' THEN s.value:value::string END) AS contentType
#               ,MAX(CASE WHEN s.value:key::string = 'appName' THEN s.value:value::string END) AS appName
#               ,MAX(CASE WHEN s.value:key::string = 'externalTakeUri' THEN s.value:value::string END) AS externalTakeUri
#               ,MAX(CASE WHEN s.value:key::string = 'itemUri' THEN s.value:value::string END) AS itemUri
#               ,MAX(CASE WHEN s.value:key::string = 'showGradeIndicators' THEN s.value:value::string END) AS showGradeIndicators
#               ,MAX(CASE WHEN s.value:key::string = 'courseUri' THEN s.value:value::string END) AS courseUri
#               ,MAX(CASE WHEN s.value:key::string = 'attemptId' THEN s.value:value::string END) AS attemptId
#               ,MAX(CASE WHEN s.value:key::string = 'activityUri' THEN s.value:value::string END) AS activityUri
#               ,MAX(CASE WHEN s.value:key::string = 'claPageNumber' THEN s.value:value::string END) AS claPageNumber
#               ,MAX(CASE WHEN s.value:key::string = 'numberOfPages' THEN s.value:value::string END) AS numberOfPages
#               ,MAX(CASE WHEN s.value:key::string = 'studyToolCgi' THEN s.value:value::string END) AS studyToolCgi
#               ,MAX(CASE WHEN s.value:key::string = 'sequenceUuid' THEN s.value:value::string END) AS sequenceUuid
#               ,MAX(CASE WHEN s.value:key::string = 'pointInSemester' THEN s.value:value::string END) AS pointInSemester
#               ,MAX(CASE WHEN s.value:key::string = 'discipline' THEN s.value:value::string END) AS discipline
#               ,MAX(CASE WHEN s.value:key::string = 'ISBN' THEN s.value:value::string END) AS ISBN
#               ,MAX(CASE WHEN s.value:key::string = 'institutionId' THEN s.value:value::string END) AS institutionId
#               ,MAX(CASE WHEN s.value:key::string = 'industryLinkURL' THEN s.value:value::string END) AS industryLinkURL
#               ,MAX(CASE WHEN s.value:key::string = 'industryLinkType' THEN s.value:value::string END) AS industryLinkType
#               ,MAX(CASE WHEN s.value:key::string = 'userRole' THEN s.value:value::string END) AS userRole
#               ,MAX(CASE WHEN s.value:key::string = 'titleIsbn' THEN s.value:value::string END) AS titleIsbn
#           FROM cap_eventing.prod.client_activity_event wa
#           CROSS JOIN LATERAL FLATTEN(WA.tags,outer=>true) s
#           GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
#         )
#         ,mapped_cap as
#         (
#         Select
#             cs.*,
#             COALESCE(m.primary_guid, cs.user_sso_guid) AS merged_guid
#             ,CONCAT(event_action,CONCAT(' - ',event_category)) as event_name
#         from cae cs --CAP_EVENTING.PROD.CLIENT_ACTIVITY_EVENT cs
#         LEFT JOIN prim_map m on cs.user_sso_guid = m.partner_guid
#         )
#         Select
#           CASE WHEN event_name ilike 'Load%sidebar' THEN 'Yes' ELSE 'No' END AS is_load_sidebar
#           ,Rank() over (partition by user_sso_guid order by event_time) as event_rank
#           ,LAG(session_id,1) OVER (PARTITION BY user_sso_guid,session_id ORDER BY event_time) AS lag_session
#           ,LEAD(event_name, 1) OVER (PARTITION BY user_sso_guid ORDER BY event_time,session_id,event_name) AS event_1
#           ,LEAD(event_name, 2) OVER (PARTITION BY user_sso_guid ORDER BY event_time,session_id, event_name) AS event_2
#           ,LEAD(event_name, 3) OVER (PARTITION BY user_sso_guid ORDER BY event_time,session_id, event_name) AS event_3
#           ,LEAD(event_name, 4) OVER (PARTITION BY user_sso_guid ORDER BY event_time,session_id, event_name) AS event_4
#           ,LEAD(event_name, 5) OVER (PARTITION BY user_sso_guid ORDER BY event_time,session_id, event_name) AS event_5
#           ,*
#         from  mapped_cap
#         ;;
#         persist_for: "6 hours"
# }
#
#   dimension: institutionId {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."INSTITUTIONALID" ;;
#   }
#   dimension: industryLinkURL {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."INDUSTRYLINKURL" ;;
#   }
#   dimension: industryLinkType {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."INDUSTRYLINKTYPE" ;;
#   }
#   dimension: userRole {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."USERROLE" ;;
#   }
#   dimension: titleIsbn {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."TITLEISBN" ;;
#   }
#
#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }
#
#     measure: industry_linkurl_count {
#     type: count_distinct
#     sql:  ${industryLinkURL};;
#     drill_fields: [detail*]
#   }
#
#   measure: user_count {
#     type: count_distinct
#     sql:  ${user_sso_guid};;
#     drill_fields: [detail*]
#   }
#
# #   measure: user_count {
# #     type: count_distinct
# #     sql_distinct_key: ${user_sso_guid} ;;
# #     drill_fields: [detail*]
# #   }
#
#   dimension: lag_session {
#     hidden: yes
#   }
#
#   dimension: event_rank {}
#
#   dimension: is_first_session {
#     sql: CASE WHEN ${lag_session} IS NULL THEN 'Yes' ELSE 'No' END ;;
#   }
#
#   dimension: merged_guid {
#     type: string
# #     sql: ${TABLE}."merged_guid" ;;
#   }
#
#   dimension: event_name_ {
#     sql: ${TABLE}."EVENT_NAME" ;;
#     label: "Event name"
#     group_label: "Event classification"
#   }
#
#   dimension: event_name {
#     label: "event_0"
#     group_label: "Succeeding five events"
#   }
#
#
#   dimension: event_1 {
#     group_label: "Succeeding five events"
#     type: string
#   }
#
#   dimension: event_2 {
#     type: string
#     group_label: "Succeeding five events"
#   }
#
#   dimension: event_3 {
#     type: string
#     group_label: "Succeeding five events"
#   }
#
#   dimension: event_4 {
#     type: string
#     group_label: "Succeeding five events"
#   }
#
#   dimension: event_5 {
#     type: string
#     group_label: "Succeeding five events"
#   }
#
#   dimension_group: _ldts {
#     type: time
#     sql: ${TABLE}."_LDTS" ;;
#     hidden: yes
#   }
#
#   dimension: _rsrc {
#     type: string
#     sql: ${TABLE}."_RSRC" ;;
#     hidden: yes
#   }
#
#   dimension: message_format_version {
#     type: number
#     sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
#   }
#
#   dimension: message_type {
#     type: string
#     sql: ${TABLE}."MESSAGE_TYPE" ;;
#   }
# #
# #   dimension_group: event_time {
# #     type: time
# #     sql: ${TABLE}."EVENT_TIME" ;;
# #   }
#
#   dimension_group: event_time {
#     group_label: "Event time"
#     type: time
#     timeframes: [raw, hour_of_day, hour, date, week, month, month_name, year]
#   }
#
#   dimension: event_hour {
#     group_label: "Event time"
#     label: "Event hour"
#     type: date_hour
#     sql: date_trunc('hour', ${TABLE}."EVENT_TIME") ;;
#     hidden: yes
#   }
#
#   dimension: event_date {
#     group_label: "Event time"
#     label: "Event date"
#     type: date
#     sql: ${TABLE}."EVENT_TIME"::DATE ;;
#     hidden: yes
#   }
#
#   dimension: event_week {
#     group_label: "Event time"
#     label: "Event week"
#     type: date
#     sql: DATE_TRUNC('week', ${TABLE}."EVENT_TIME" );;
#     hidden: yes
#   }
#
#   dimension: event_month {
#     group_label: "Event time"
#     label: "Event month"
#     type: date
#     sql: date_trunc('week', ${TABLE}."EVENT_TIME") ;;
#     hidden: yes
#   }
#
#
#
#
#   dimension: event_duration {
#     type: number
#     sql: ${TABLE}."EVENT_DURATION" ;;
#   }
#
#   dimension: event_category {
#     type: string
#     sql: ${TABLE}."EVENT_CATEGORY" ;;
#     group_label: "Event classification"
#   }
#
#   dimension: event_action {
#     type: string
#     sql: ${TABLE}."EVENT_ACTION" ;;
#     group_label: "Event classification"
#   }
#
#   dimension: is_load_sidebar {
#     label: "Is Load Sidebar Event"
#     description: "Make this filtered to 'No' to remove LOAD SIDEBAR events"
#     type: string
#   }
#
#   dimension: product_platform {
#     type: string
#     sql: ${TABLE}."PRODUCT_PLATFORM" ;;
#     group_label: "Event classification"
#   }
#
#   dimension: product_environment {
#     type: string
#     sql: ${TABLE}."PRODUCT_ENVIRONMENT" ;;
#   }
#
#   dimension: user_platform {
#     type: string
#     sql: ${TABLE}."USER_PLATFORM" ;;
#   }
#
#   dimension: user_environment {
#     type: string
#     sql: ${TABLE}."USER_ENVIRONMENT" ;;
#   }
#
#   dimension: host_platform {
#     type: string
#     sql: ${TABLE}."HOST_PLATFORM" ;;
#     group_label: "Event classification"
#   }
#
#   dimension: host_environment {
#     type: string
#     sql: ${TABLE}."HOST_ENVIRONMENT" ;;
#   }
#
#   dimension: session_id {
#     type: string
#     sql: ${TABLE}."SESSION_ID" ;;
#   }
#
#   dimension: event_id {
#     type: string
#     sql: ${TABLE}."EVENT_ID" ;;
#   }
#
#   dimension: user_sso_guid {
#     type: string
#     sql: ${TABLE}."USER_SSO_GUID" ;;
#     hidden: yes
#   }
#
#   dimension: event_uri {
#     type: string
#     sql: ${TABLE}."EVENT_URI" ;;
#   }
#
#   dimension: tags {
#     type: string
#     sql: ${TABLE}."TAGS" ;;
#   }
#
#   dimension: coursekey {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."COURSEKEY" ;;
#   }
#
#   dimension: carouselname {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."CAROUSELNAME" ;;
#   }
#
#   dimension: carouselsessionid {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."CAROUSELSESSIONID" ;;
#   }
#
#   dimension: activityid {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."ACTIVITYID" ;;
#   }
#
#   dimension: checkpointid {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."CHECKPOINTID" ;;
#   }
#
#   dimension: contenttype {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."CONTENTTYPE" ;;
#   }
#
#   dimension: appname {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."APPNAME" ;;
#   }
#
#   dimension: externaltakeuri {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."EXTERNALTAKEURI" ;;
#   }
#
#   dimension: itemuri {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."ITEMURI" ;;
#   }
#
#   dimension: showgradeindicators {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."SHOWGRADEINDICATORS" ;;
#   }
#
#   dimension: courseuri {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."COURSEURI" ;;
#   }
#
#   dimension: attemptid {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."ATTEMPTID" ;;
#   }
#
#   dimension: activityuri {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."ACTIVITYURI" ;;
#   }
#
#   dimension: clapagenumber {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."CLAPAGENUMBER" ;;
#   }
#
#   dimension: numberofpages {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."NUMBEROFPAGES" ;;
#   }
#
#   dimension: studytoolcgi {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."STUDYTOOLCGI" ;;
#   }
#
#   dimension: sequenceuuid {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."SEQUENCEUUID" ;;
#   }
#
#   dimension: pointinsemester {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."POINTINSEMESTER" ;;
#   }
#
#   dimension: discipline {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."DISCIPLINE" ;;
#   }
#
#   dimension: isbn {
#     group_label: "Tags meta data"
#     type: string
#     sql: ${TABLE}."ISBN" ;;
#   }
#
#
#   set: detail {
#     fields: [
#       _ldts_time,
#       _rsrc,
#       message_format_version,
#       message_type,
#       # event_time_time,
#       event_duration,
#       event_category,
#       event_action,
#       product_platform,
#       product_environment,
#       user_platform,
#       user_environment,
#       host_platform,
#       host_environment,
#       session_id,
#       event_id,
#       user_sso_guid,
#       event_uri,
#       tags
#     ]
#   }
# }
