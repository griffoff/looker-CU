explore: cas_cafe_student_activity_duration {hidden:yes}
view: cas_cafe_student_activity_duration {
  derived_table: {
    create_process: {
      sql_step:
        use warehouse heavyduty
      ;;
      sql_step:
        create or replace transient table looker_scratch.activity_labels as (
          with recursive origins (activity_name, activity_id, snapshot_id, level, id, parent_id, node_type, name) as (
            select name, id, snapshot_id, 0, id, parent_id, node_type, name
            from mindtap.prod_nb.node n1
            where node_type = 'com.cengage.nextbook.learningunit.Activity' and origin_id is null and id <> parent_id
            union all
            select
              origins.activity_name,
              origins.activity_id,
              origins.snapshot_id,
              level + 1,
              n1.id,
              n1.parent_id,
              n1.node_type,
              n1.name
            from mindtap.prod_nb.node n1 join origins
            on n1.id = origins.parent_id and origins.id <> origins.parent_id and n1.parent_id <> origins.id and n1.id <> n1.parent_id
            where n1.node_type not in ('com.cengage.nextbook.NextBook')
          )
          , activity as (
            select n1.activity_name, n1.activity_id, n1.snapshot_id, o.external_id, a.ref_id, a.is_gradable, n1.node_type, n1.name
            from origins n1
            left join mindtap.prod_nb.activity a on a.id = n1.activity_id
            left join mindtap.prod_nb.snapshot s on s.id = n1.snapshot_id
            left join mindtap.prod_nb.org o on s.org_id = o.id
            where n1.node_type <> 'com.cengage.nextbook.learningunit.Activity'
          )
          select *
          from activity a
          pivot(max(name) for node_type in (
            'com.cengage.nextbook.learningunit.LearningUnit',
            'com.cengage.nextbook.learningunit.Group',
            'com.cengage.nextbook.learningpath.LearningPath'
          )) as p (activity_name,activity_id,snapshot_id,external_id,ref_id,is_gradable,learning_unit_name,group_name,learning_path_name)
        )
      ;;
      sql_step:
        SET max_gap_minutes = 20
      ;;
      sql_step:
        SET max_duration_minutes = 20
      ;;
      sql_step:
        SET min_date = '2019-08-01'
      ;;
      sql_step:
        SET start_time = CURRENT_TIMESTAMP()
      ;;
      sql_step:
        CREATE OR REPLACE TRANSIENT TABLE looker_scratch.session_event_durations AS (
          WITH activities AS (
          select distinct
            o.external_id as course_key
            , a.ref_id
            , a.is_gradable
            , to_timestamp(n.end_date, 3) as due_date
            , to_timestamp(n.created_date, 3) as effective_from
            , lead(effective_from) over (partition by course_key,a.ref_id order by effective_from) as effective_to
            , coalesce(al.activity_name, n.name) as activity_name
            , al.learning_unit_name
            , al.group_name
            , al.learning_path_name
          from mindtap.prod_nb.activity a
          inner join mindtap.prod_nb.node n on n.id = a.id
          left join looker_scratch.activity_labels al on n.origin_id = al.activity_id
          inner join mindtap.prod_nb.snapshot s on s.id = n.snapshot_id
          inner join mindtap.prod_nb.org o on s.org_id = o.id
          )
          SELECT *
            , lag(event_time) OVER (PARTITION BY merged_guid, session_partition ORDER BY event_time) AS prev_event_time
            , lead(event_time) OVER (PARTITION BY merged_guid, session_partition, active_time_partition ORDER BY event_time) AS next_event_time
            , lead(event_time) OVER (PARTITION BY merged_guid, session_partition ORDER BY event_time) AS next_event_time_user
            , datediff(MILLISECOND, prev_event_time, event_time) / 1000.000 AS time_from_prev_event_seconds         --used to find long gaps in order to split sessions
            , datediff(MILLISECOND, event_time, next_event_time) / 1000.000 AS time_to_next_session_event_seconds   --used to calculate time spent within the session
            , datediff(MILLISECOND, event_time, next_event_time_user) / 1000.000 AS time_to_next_user_event_seconds --to see how long until the user does something else (could be days)
            , CASE
                WHEN LEAST(time_to_next_session_event_seconds, time_to_next_user_event_seconds) > $max_duration_minutes * 60 THEN 0
                ELSE LEAST(time_to_next_session_event_seconds, time_to_next_user_event_seconds)
            END AS duration
          FROM (
            select distinct
              event_time
              , event_action
              , event_category
              , coalesce(su.linked_guid, hu.uid) AS merged_guid
              --session_partition
              -- define which value to use as a hard session boundary
              -- in addition to the max_gap_minutes parameter
              -- and merged_guid, which is always used
              -- set to a constant value to only partition on merged_guid
              -- i.e. Any event that has a different session_partition or is [max_gap_minutes] after the previous event will trigger a new session
              , event_tags:activityId::string as session_partition
              --active_time_partition:
              -- define the value for which you want to use as the boundary for calculating event duration
              -- when this value changes between two consecutive events for the same user
              -- the duration will be NULL
              -- i.e. when duration is NULL it is assumed that it represents a period of inactivity
              , event_tags:attemptId::string AS active_time_partition
              , event_tags:attemptId::string AS attempt_id
              , event_tags:activityId::string AS activity_id
              , event_tags:courseUri::string AS course_uri
              , event_tags:activityUri::string AS activity_uri
              , event_tags:claPageNumber AS cla_page_number
              , event_tags:numberOfPages AS number_of_pages
              , a.is_gradable
              , a.due_date
              , a.activity_name
              , a.learning_unit_name
              , a.group_name
              , a.learning_path_name
              , REGEXP_SUBSTR(event_tags:"courseUri", '.*course-key:(.+)$', 1, 1, 'e') as course_key
              , REGEXP_SUBSTR(event_tags:"activityUri", '.*ref-id:(.+)$', 1, 1, 'e') as ref_id
          FROM prod.datavault.sat_common_event_client_activity se
          INNER JOIN prod.datavault.link_user_platform lup USING (link_user_platform_key)
          INNER JOIN prod.datavault.hub_platform hp ON lup.hub_platform_key = hp.hub_platform_key
          INNER JOIN prod.datavault.sat_user_v2 su ON lup.hub_user_key = su.hub_user_key AND su._latest
          INNER JOIN prod.datavault.hub_user hu ON su.hub_user_key = hu.hub_user_key
          LEFT JOIN prod.datavault.sat_user_internal sui ON hu.hub_user_key = sui.hub_user_key AND sui.active AND sui.internal
          LEFT JOIN activities a ON a.ref_id = REGEXP_SUBSTR(event_tags:"activityUri", '.*ref-id:(.+)$', 1, 1, 'e')
            AND a.course_key = REGEXP_SUBSTR(event_tags:"courseUri", '.*course-key:(.+)$', 1, 1, 'e')
            AND se.event_time BETWEEN a.effective_from AND COALESCE(a.effective_to,CURRENT_DATE)
          WHERE hp.environment = 'production'
            AND hp.platform = 'cas-mt'
            AND sui.internal IS NULL               --exclude internal users
            AND NOT coalesce(su.instructor, FALSE) --exclude instructors
            AND se.event_time >= $min_date
            AND se.event_time <= CURRENT_TIMESTAMP()
          )
          ORDER BY event_time
        )
      ;;
      sql_step:
      CREATE OR REPLACE TRANSIENT TABLE ${SQL_TABLE_NAME} AS (
        select
          merged_guid
          , activity_id::string as activity_id
          , active_time_partition as activity_session_id
          , is_gradable
          , due_date
          , activity_name
          , learning_unit_name
          , group_name
          , learning_path_name
          , course_key
          , hash(merged_guid,activity_id,activity_session_id,is_gradable,due_date,activity_name,learning_unit_name,group_name,course_key) as pk
          , min(event_time) as activity_session_start
          , max(dateadd(seconds,duration,event_time)) as activity_session_complete
          , sum(duration) as activity_session_duration
        from looker_scratch.session_event_durations
        group by 1,2,3,4,5,6,7,8,9,10,11
      )
      ;;
      sql_step:
        alter warehouse heavyduty suspend
      ;;
      sql_step:
        use warehouse analysis
      ;;
    }
    datagroup_trigger: daily_refresh
  }


  dimension: pk {
    primary_key: yes
    hidden: yes
  }

  dimension: activity_counts_toward_grade {
    sql: case when ${TABLE}.due_date is not null and ${TABLE}.is_gradable then true else false end  ;;
    type: yesno
    description: "Activity has 'is gradable' flag and due date is not null"
  }

  dimension: merged_guid {}
  dimension: activity_id {}
  dimension: activity_session_id {}

  dimension: is_gradable {
    type: yesno
    sql: coalesce(${TABLE}.is_gradable,false) ;;
  }

  dimension_group: due_date  {
    type: time
    label: "Due"
    timeframes: [raw,date,week,month,year,time]
  }

  dimension_group: activity_session_start {
    type: time
    label: "Activity Session Start"
    timeframes: [raw,date,week,month,year,time]
  }

  dimension_group: activity_session_complete {
    type: time
    label: "Activity Session Complete"
    timeframes: [raw,date,week,month,year,time]
  }

  dimension: activity_name {}
  dimension: learning_unit_name {}
  dimension: group_name {}
  dimension: learning_path_name {}
  dimension: course_key {}

  dimension: activity_session_duration {
    type: number
    sql: ${TABLE}.activity_session_duration / 60 / 60 / 24 ;;
    value_format_name: duration_minutes
  }

  measure: number_users {
    type: count_distinct
    sql: ${merged_guid};;
    label: "# Users"
  }

  measure: average_activity_duration {
    type: average
    sql: ${activity_session_duration};;
    value_format_name: duration_minutes
  }

  measure: duration_p10 {
    group_label: "Activity Duration"
    type: percentile
    percentile: 10
    sql: ${activity_session_duration};;
    value_format_name: duration_minutes
  }

  measure: duration_p25 {
    group_label: "Activity Duration"
    type: percentile
    percentile: 25
    sql: ${activity_session_duration};;
    value_format_name: duration_minutes
  }

  measure: duration_p50 {
    group_label: "Activity Duration"
    type: percentile
    percentile: 50
    sql: ${activity_session_duration};;
    value_format_name: duration_minutes
  }

  measure: duration_p75 {
    group_label: "Activity Duration"
    type: percentile
    percentile: 75
    sql: ${activity_session_duration};;
    value_format_name: duration_minutes
  }

  measure: duration_p90 {
    group_label: "Activity Duration"
    type: percentile
    percentile: 90
    sql: ${activity_session_duration};;
    value_format_name: duration_minutes
  }

  measure: count {
    type: count
  }


  }
