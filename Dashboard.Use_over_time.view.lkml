view: dashboard_use_over_time {
  derived_table: {
    sql: WITH
        state AS (
            SELECT
                TO_CHAR(TO_DATE(raw_subscription_event."SUBSCRIPTION_START" ), 'YYYY-MM-DD') AS sub_start_date
                ,RANK () OVER (PARTITION BY user_sso_guid ORDER BY LOCAL_Time DESC) AS latest_record
                ,RANK () OVER (PARTITION BY user_sso_guid ORDER BY LOCAL_Time ASC) AS earliest_record
                ,LEAD(subscription_state) over(partition by user_sso_guid order by local_time) as change_in_state
                ,LEAD(subscription_start) over(partition by user_sso_guid order by local_time) as change_in_start_date
                ,*
            FROM prod.unlimited.Raw_Subscription_event
            --WHERE user_sso_guid NOT IN (SELECT user_sso_guid FROM unlimited.vw_user_blacklist)
            )

          ,days_active AS
              (SELECT
                userssoguid
                ,COUNT( DISTINCT(DATE_TRUNC(day, (TO_DATE(TO_TIMESTAMP(((VISITSTARTTIME*1000) + hits_time )/1000) ))))) AS num_days_active
              FROM prod.raw_ga.ga_dashboarddata
              GROUP BY 1)


         ,first_login AS (
              SELECT
                userssoguid
                ,MIN(TO_DATE(TO_TIMESTAMP(((VISITSTARTTIME*1000) + hits_time )/1000) )) AS first_login
                ,DATEDIFF(day, first_login, DATEADD(day, -1, current_timestamp())) AS days_since_first_login
              FROM prod.raw_ga.ga_dashboarddata
              WHERE userssoguid IS NOT NULL
              GROUP BY 1 )

        ,dashboard AS (
              SELECT
                ga.userssoguid
                ,fl.first_login
                ,fl.days_since_first_login
                ,da.num_days_active
                ,(da.num_days_active / fl.days_since_first_login ) * 100 AS percent_days_active
                ,TO_DATE(TO_TIMESTAMP(((VISITSTARTTIME*1000) + hits_time )/1000) ) AS visitstarttime
                ,DATEDIFF('day',  fl.first_login, (TO_DATE(TO_TIMESTAMP(((ga.VISITSTARTTIME*1000) + hits_time )/1000) ))) AS event_age
                ,ga.eventaction
                ,ga.eventlabel
                ,ga.eventcategory
                ,ga.pagepath
              FROM prod.raw_ga.ga_dashboarddata ga
              JOIN first_login fl
              ON ga.userssoguid = fl.userssoguid
              AND ga.userssoguid IS NOT NULL
              JOIN days_active da
              ON ga.userssoguid = da.userssoguid)


        SELECT
            s.*
            ,CASE WHEN s.latest_record = 1 THEN 'yes' ELSE 'no' END AS latest_filter
            ,CASE WHEN s.earliest_record = 1 THEN 'yes' ELSE 'no' END AS earliest_filter
            ,d.first_login
            ,d.days_since_first_login
            ,d.num_days_active
            ,d.percent_days_active
            ,d.visitstarttime
            ,d.event_age
            ,d.eventaction
            ,d.eventlabel
            ,d.eventcategory
            ,d.pagepath
          FROM state s
          JOIN dashboard d
          ON s.user_sso_guid = d.userssoguid


          LEFT JOIN unlimited.vw_user_blacklist bk
          ON s.user_sso_guid = bk.user_sso_guid
          WHERE bk.user_sso_guid IS NULL
 ;;
  }

  dimension: days_since_first_login {
    type: number
    }

  dimension: num_days_active {
    type: number
  }

  dimension: percent_days_active {
    type: number
  }

  dimension: latest_subscription {
    label: "Current subscription status"
    description: "filter used to retrive the latest subscription status for a user"
    type: yesno
    sql: ${TABLE}.latest_filter = 'yes'  ;; }


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: sub_start_date {
    type: string
    sql: ${TABLE}."SUB_START_DATE" ;;
  }

  dimension: latest_record {
    type: number
    sql: ${TABLE}."LATEST_RECORD" ;;
  }

  dimension: earliest_record {
    type: number
    sql: ${TABLE}."EARLIEST_RECORD" ;;
  }

  dimension: change_in_state {
    type: string
    sql: ${TABLE}."CHANGE_IN_STATE" ;;
  }

  dimension_group: change_in_start_date {
    type: time
    sql: ${TABLE}."CHANGE_IN_START_DATE" ;;
  }

  dimension: _hash {
    type: string
    sql: ${TABLE}."_HASH" ;;
  }

  dimension_group: _ldts {
    type: time
    sql: ${TABLE}."_LDTS" ;;
  }

  dimension: _rsrc {
    type: string
    sql: ${TABLE}."_RSRC" ;;
  }

  dimension: message_format_version {
    type: number
    sql: ${TABLE}."MESSAGE_FORMAT_VERSION" ;;
  }

  dimension: message_type {
    type: string
    sql: ${TABLE}."MESSAGE_TYPE" ;;
  }

  dimension_group: local_time {
    type: time
    sql: ${TABLE}."LOCAL_TIME" ;;
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: user_environment {
    type: string
    sql: ${TABLE}."USER_ENVIRONMENT" ;;
  }

  dimension: product_platform {
    type: string
    sql: ${TABLE}."PRODUCT_PLATFORM" ;;
  }

  dimension: platform_environment {
    type: string
    sql: ${TABLE}."PLATFORM_ENVIRONMENT" ;;
  }

  dimension_group: subscription_start {
    type: time
    sql: ${TABLE}."SUBSCRIPTION_START" ;;
  }

  dimension_group: subscription_end {
    type: time
    sql: ${TABLE}."SUBSCRIPTION_END" ;;
  }

  dimension: subscription_state {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_STATE" ;;
  }

  dimension: contract_id {
    type: string
    sql: ${TABLE}."CONTRACT_ID" ;;
  }

  dimension: latest_filter {
    type: string
    sql: ${TABLE}."LATEST_FILTER" ;;
  }

  dimension: earliest_filter {
    type: string
    sql: ${TABLE}."EARLIEST_FILTER" ;;
  }

  dimension: first_login {
    type: date
    sql: ${TABLE}."FIRST_LOGIN" ;;
  }

  dimension: visitstarttime {
    type: date
    sql: ${TABLE}."VISITSTARTTIME" ;;
  }

  dimension: event_age {
    type: number
    sql: ${TABLE}."EVENT_AGE" ;;
  }

  measure: user_count {
    type: count_distinct
    sql:  ${user_sso_guid} ;;
  }

  measure: event_day_count {
    type: count_distinct
    sql: ${event_age} ;;
  }

  measure: percent_days_active_m {
    type: number
    sql: ( num_days_active / days_since_first_login) * 100.00 ;;
    value_format: "#.00\%"
  }

  dimension: eventaction {
    type: string
    sql: ${TABLE}."EVENTACTION" ;;
  }

  dimension: eventlabel {
    type: string
    sql: ${TABLE}."EVENTLABEL" ;;
  }

  dimension: eventcategory {
    type: string
    sql: ${TABLE}."EVENTCATEGORY" ;;
  }

  dimension: pagepath {
    type: string
    sql: ${TABLE}."PAGEPATH" ;;
  }

  dimension: Added_content{
    label: "Event Dimensions"
    type: string
    sql: case when eventaction like 'Calls To Action (CTAs)' and eventlabel like 'Add To My Content Position%' then 'Added Content To Dashboard'
              when eventaction like 'Search Term%'  then 'Searched Items With Results'
              when eventaction like 'Calls To Action (CTAs)' and LOWER(eventlabel) like 'dashboard%ebook%' then 'eBook launched'
              when eventaction like 'Dashboard Course Launched Name%' then 'Courseware launched'
              when eventaction like 'Explore Catalog%' then 'Catalog explored'
              when eventaction like 'Rent From Chegg%'  then 'Rented from Chegg clicks'
              when eventaction like 'Exclusive Partner Clicked' OR eventaction like 'One Month Free Clicked' then 'One month Free Chegg clicks'
              when eventaction like 'Print Options No Results' then 'Print Options N/A'
              when eventaction like 'Search Bar No%'  then 'No Results Search'
              when eventaction like 'Support Clicked' then 'Support Clicked'
              when eventaction like '%FAQ%' then 'FAQ Clicked'
              when eventaction like 'Calls To Action (CTAs)' and eventlabel like 'Buy Now Button Click' then 'Clicked on UPGRADE (top yellow banner)'
              when eventaction like 'Calls To Action (CTAs)' and eventlabel like 'Upgrade Link%' then 'Clicked on UPGRADE (middle yellow banner)'
              when eventaction like 'Print Options Entire Catalog Clicked' then 'Searched Entire Cengage Catalog'
              when ${eventcategory} like 'Course Key Registration' then 'Course Key Registration'
              when ${eventcategory} like 'Access Code Registration' then 'Access Code Registration'
              when ${eventcategory} like 'Videos' and eventaction like 'Meet Cengage Unlimited' then 'CU videos viewed'
              when ${pagepath} like '%print-options%' and ${eventaction} IS NULL then 'Print Options Clicked'
              when ${pagepath} like '%explore-catalog%' and ${eventaction} IS NULL then 'Explore Catalog Clicked'
              when ${pagepath} like '%exclusive-partners%' and ${eventaction} IS NULL then 'Study Resources Clicked'
              when ${pagepath} like '%my-dashboard/authenticated%' and ${eventaction} IS NULL then 'My Home Clicked'
              ELSE 'Other Clicks'
              END
    ;;
  }

  set: detail {
    fields: [
      sub_start_date,
      latest_record,
      earliest_record,
      change_in_state,
      change_in_start_date_time,
      _hash,
      _ldts_time,
      _rsrc,
      message_format_version,
      message_type,
      local_time_time,
      user_sso_guid,
      user_environment,
      product_platform,
      platform_environment,
      subscription_start_time,
      subscription_end_time,
      subscription_state,
      contract_id,
      latest_filter,
      earliest_filter,
      first_login,
      visitstarttime,
      event_age,
      eventaction,
      eventlabel,
      eventcategory,
      pagepath
    ]
  }
}
