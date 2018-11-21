explore: search_outcome {label: "Search Outcome"}

view: search_outcome {
  derived_table: {
    sql: with dis_ses as (
        select distinct user_sso_guid, session_id from zpg.all_events
        where product_platform like 'CU DASHBOARD' and event_action
      ilike '%SEARCH TERM%'-- and user_sso_guid like 'fd95a962ff3f5f1e:-6663148a:165cb0d4980:-7dd1'

        --//and user_sso_guid like '8cb033b2fc245569:580660e7:1659070b5f1:5e90'
      )
      , ses_eve as (
      select
          CASE WHEN event_action ilike '%SEARCH TERM%' THEN LOWER(split_part(event_data:event_label,'|',1)) ELSE NULL END as term,
          CASE WHEN event_action ilike 'CALLS TO ACTION (CTAS)' AND LOWER(split_part(event_data:event_label,'|',1)) like 'add to my content position' THEN 'Y' ELSE 'N' END as Added,
          e.*
        from dis_ses s
          JOIN zpg.all_events e
          ON e.user_sso_guid = s.user_sso_guid
          and e.session_id = s.session_id
          WHERE e.event_type NOT IN ('ENGAGEMENT TIMER','MARKETING')
        ) --Select * from ses_eve;
       , eve_ar as (
          select
          -- array_agg(event_action) as event_array,
          LEAD(ADDED) over (partition by user_sso_guid,session_id order by event_time) AS ADDED_FLAG
          ,term as Search_term,user_sso_guid, session_id
          ,event_time,event_id
        from ses_eve
        --group by user_sso_guid, session_id
         ) select IFNULL(ADDED_FLAG,'N') AS SEARCH_OUTCOME,
            count (*) over(partition by session_id ) as no_searches,
            ev.*,cat.category
            from eve_ar ev
            LEFT JOIN uploads.cu.search_category cat
            ON ev.search_term = cat.search_term
            where ev.Search_term is NOT NULL
       ;;
      persist_for: "12 hours"
  }

  measure: count {
    label: "# searches"
    type: count
    drill_fields: [detail*]
  }

  measure: count_distinct_search {
    label: "# distinct search terms"
    type: count_distinct
    sql: ${search_term}  ;;
  }

  measure: count_distinct_user {
    label: "# users"
    type: count_distinct
    sql: ${user_sso_guid}  ;;
  }

  dimension: no_searches {
    type: number
    sql: ${TABLE}.no_searches ;;
  }

  dimension: search_outcome {
    type: string
    sql: ${TABLE}."SEARCH_OUTCOME" ;;
  }

  dimension: category {
    type: string
    sql: CASE WHEN IS_Integer(Try_To_Numeric(${TABLE}."SEARCH_TERM")) = TRUE THEN 'ISBN' ELSE ${TABLE}."CATEGORY" END ;;
  }

  dimension: added_flag {
    type: string
    sql: ${TABLE}."ADDED_FLAG" ;;
  }

  dimension: search_term {
    type: string
    sql: ${TABLE}."SEARCH_TERM" ;;
  }

  dimension: search_category {
    case: {

      when: {
        sql: IS_Integer(Try_To_Numeric(${TABLE}."SEARCH_TERM")) = TRUE ;;
        label: "ISBN"
      }
      when: {
        sql: IS_Integer(Try_To_Numeric(${TABLE}."SEARCH_TERM")) IS NULL ;;
        label: "Platform/Author/etc"
      }
    }
  }

  dimension: user_sso_guid {
    type: string
    sql: ${TABLE}."USER_SSO_GUID" ;;
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}."SESSION_ID" ;;
  }

  dimension_group: event_time {
    type: time
    sql: ${TABLE}."EVENT_TIME" ;;
  }

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
  }

  set: detail {
    fields: [
      search_outcome,
      added_flag,
      search_term,
      user_sso_guid,
      session_id,
      event_time_time,
      event_id
    ]
  }
}
