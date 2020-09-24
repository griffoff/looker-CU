view: cohort_selection {
  label: "** FLOW ANALYSIS **"

  filter: cohort_events_filter {
    label: "Choose starting event(s)"
    description: "Select the events that you want your analysis to start with "
    type: string
    default_value: ""
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
  }

  filter: cohort_date_range_filter {
    label: "Choose a starting date range"
    description: "Select a date range for the starting event(s)"
    type: date
    datatype: date
  }

  filter: flow_events_filter {
    label: "Events to include / exclude in the flow"
    description: "Select the things that you want to include or exclude in your flow"
    type: string
    default_value: ""
    suggest_explore: filter_cache_all_events_event_name
    suggest_dimension: filter_cache_all_events_event_name.event_name
  }

  parameter: bucket_other_events {
    label: "Bucket 'other' events"
    description: "Do you want to include all events, but bucket ones not in your event filter under a single category 'Other'"
    type: unquoted
    allowed_value: {label: "Bucket all events not in your filter as 'Other'" value:"bucket"}
    allowed_value: {label: "Exclude all events not in your filter" value:"exclude"}
    default_value: "exclude"
  }

  parameter: before_or_after {

    label: "Before or after analysis?"
    description: "Do you want to find behaviors before (leading up to) or after (happened after) the chosen cohort behavior?"
    type: unquoted
    default_value: "after"
    allowed_value: {label: "Before" value: "before"}
    allowed_value: {label: "After" value: "after"}
  }

  parameter: sample_size {

    label: "Sample size"
    description: "How much of the data do you want to use in this analysis?  Reduce sample size to speed up the query"
    type: unquoted
    default_value: "50"
    allowed_value: {label: "25%" value: "25"}
    allowed_value: {label: "50%" value: "50"}
    allowed_value: {label: "75%" value: "75"}
    allowed_value: {label: "No sampling" value: "100"}
  }

  parameter: ignore_duplicates {

    label: "Ignore duplicate events?"
    description: "Do you want to ignore consecutive events that are the same (e.g. only count the first page view in an ebook session)?"
    type: unquoted
    default_value: "exclude"
    allowed_value: {label:"Exclude duplicates" value:"exclude"}
    allowed_value: {label:"Include all events" value:"include"}
  }

  parameter: time_period {

    label: "Include events (n) minutes before/after the initial behavior"
    description: "How long after the initial behavior (within the same session) do you want to look for subsequent actions"
    type: number
  }

  derived_table: {

    sql:
      SELECT
          user_sso_guid
          ,start_events
          ,MAX(CASE WHEN event_sequence = 1 THEN event_name END) as event_1
          ,MAX(CASE WHEN event_sequence = 2 THEN event_name END) as event_2
          ,MAX(CASE WHEN event_sequence = 3 THEN event_name END) as event_3
          ,MAX(CASE WHEN event_sequence = 4 THEN event_name END) as event_4
          ,MAX(CASE WHEN event_sequence = 5 THEN event_name END) as event_5
        FROM (
          SELECT
              {% if before_or_after._parameter_value == 'before' %}
              ROW_NUMBER() OVER(PARTITION BY flow_events.session_id ORDER BY event_time DESC, event_id DESC) AS event_sequence
              {% else %}
              ROW_NUMBER() OVER(PARTITION BY flow_events.session_id ORDER BY event_time, event_id) AS event_sequence
              {% endif %}
              ,starting_events.start_events
              ,COALESCE(flow_events.USER_SSO_GUID,starting_events.USER_SSO_GUID) AS user_sso_guid
              ,flow_events.new_event_name as event_name
          FROM (
            SELECT
              all_events.user_sso_guid
              ,all_events.session_id
              ,LISTAGG(distinct event_name) as start_events, min(event_time) as start_event_time
              ,MIN(all_events.event_id) as first_event_id
              ,CASE
                WHEN {{ time_period._parameter_value }} IS NULL THEN NULL
                ELSE
                  DATEADD(minute,  IFF('{% parameter before_or_after %}' = 'before', -1, 1) * {{ time_period._parameter_value }}, start_event_time)
                END as boundary_event_time
            FROM ${all_sessions.SQL_TABLE_NAME} all_sessions SAMPLE({{ sample_size._parameter_value }}) REPEATABLE(0)
            INNER JOIN ${all_events.SQL_TABLE_NAME} all_events USING (session_id)
            WHERE (DATEADD(day, 1, session_start::DATE) >= {% date_start cohort_date_range_filter %} OR {% date_start cohort_date_range_filter %} IS NULL)
            AND (DATEADD(day, -1, session_start::DATE) < {% date_end cohort_date_range_filter %} OR {% date_end cohort_date_range_filter %} IS NULL)
            AND {% condition cohort_events_filter %} event_name {% endcondition %}
            GROUP BY 1, 2
            ) starting_events
          LEFT JOIN (
              SELECT
                all_events.event_time
                ,all_events.session_id
                ,all_events.event_id
                ,all_events.user_sso_guid
                ,
                {% if bucket_other_events._parameter_value == 'bucket' %}
                  CASE WHEN {% condition flow_events_filter %} event_name {% endcondition %}
                    THEN all_events.event_name ELSE '* Other Event(s) *' END
                {% else %}
                  all_events.event_name
                {% endif %}
                  AS new_event_name
                ,
                {% if before_or_after._parameter_value == 'before' %}
                    LEAD(new_event_name) OVER(PARTITION BY user_sso_guid ORDER BY event_time) = new_event_name
                {% else %}
                    LAG(new_event_name) OVER(PARTITION BY user_sso_guid ORDER BY event_time) = new_event_name
                {% endif %}
                  AS is_duplicate
              FROM ${all_sessions.SQL_TABLE_NAME} all_sessions SAMPLE({{ sample_size._parameter_value }}) REPEATABLE(0)
              INNER JOIN ${all_events.SQL_TABLE_NAME} all_events USING (session_id)
              WHERE (DATEADD(day, 1, session_start::DATE) >= {% date_start cohort_date_range_filter %} OR {% date_start cohort_date_range_filter %} IS NULL)
              AND (DATEADD(day, -1, session_start::DATE) < {% date_end cohort_date_range_filter %} OR {% date_end cohort_date_range_filter %} IS NULL)
              {% if bucket_other_events._parameter_value != 'bucket' %}
                AND {% condition flow_events_filter %} event_name {% endcondition %}
              {% endif %}
          ) flow_events ON starting_events.session_id = flow_events.session_id
            {% if ignore_duplicates._parameter_value == 'exclude' %}
                    --remove all duplicate events
                    AND NOT flow_events.is_duplicate
            {% else %}
                    -- only de duplicate the 'Other' bucket
                    AND (new_event_name != '* Other Event(s) *' OR NOT flow_events.is_duplicate)
            {% endif %}

            {% if before_or_after._parameter_value == 'before' %}
              --PRECEDING EVENT ANALYSIS
                    AND flow_events.event_time < starting_events.start_event_time
                    AND (
                      flow_events.event_time > starting_events.boundary_event_time
                      OR starting_events.boundary_event_time IS NULL
                    )
            {% else %}
            --SUBSEQUENT EVENT ANALYSIS
                    AND flow_events.event_time > starting_events.start_event_time
                    AND (
                      flow_events.event_time < starting_events.boundary_event_time
                      OR starting_events.boundary_event_time IS NULL
                    )
            {% endif %}
          )
        WHERE event_sequence <= 5
        GROUP BY 1, 2
        ;;
  }

  dimension: user_sso_guid {hidden:yes primary_key:yes}
  dimension: start_events { type: string description: "The events selected as your starting point" alias:[cohort_events]}
#   dimension: event_sequence { type: number}
#   dimension: event_sequence_description { type: string sql: ${event_sequence} || ' event' || IFF(${event_sequence} > 1, 's ', ' ') || '{% parameter before_or_after %}';; order_by_field: event_sequence}
  dimension: event_1 { type: string  group_label: "Events after" label: "1 event after" sql: {% if before_or_after._parameter_value == "after" %} ${TABLE}.event_1 {% else %} NULL {% endif%} ;;}
  dimension: event_2 { type: string  group_label: "Events after" label: "2 events after" sql: {% if before_or_after._parameter_value == "after" %} ${TABLE}.event_2 {% else %} NULL {% endif%} ;;}
  dimension: event_3 { type: string  group_label: "Events after" label: "3 events after" sql: {% if before_or_after._parameter_value == "after" %} ${TABLE}.event_3 {% else %} NULL {% endif%} ;;}
  dimension: event_4 { type: string  group_label: "Events after" label: "4 events after" sql: {% if before_or_after._parameter_value == "after" %} ${TABLE}.event_4 {% else %} NULL {% endif%} ;;}
  dimension: event_5 { type: string  group_label: "Events after" label: "5 events after" sql: {% if before_or_after._parameter_value == "after" %} ${TABLE}.event_5 {% else %} NULL {% endif%} ;;}
  dimension: event_1_p { type: string  group_label: "Events before" label: "1 event before" sql: {% if before_or_after._parameter_value == "before" %} ${TABLE}.event_1 {% else %} NULL {% endif%} ;;}
  dimension: event_2_p { type: string  group_label: "Events before" label: "2 events before" sql: {% if before_or_after._parameter_value == "before" %} ${TABLE}.event_2 {% else %} NULL {% endif%} ;;}
  dimension: event_3_p { type: string  group_label: "Events before" label: "3 events before" sql: {% if before_or_after._parameter_value == "before" %} ${TABLE}.event_3 {% else %} NULL {% endif%} ;;}
  dimension: event_4_p { type: string  group_label: "Events before" label: "4 events before" sql: {% if before_or_after._parameter_value == "before" %} ${TABLE}.event_4 {% else %} NULL {% endif%} ;;}
  dimension: event_5_p { type: string  group_label: "Events before" label: "5 events before" sql: {% if before_or_after._parameter_value == "before" %} ${TABLE}.event_5 {% else %} NULL {% endif%} ;;}

  measure: user_count {
    label: "# Users"
    type: count_distinct
    sql: ${user_sso_guid} ;;
    link: {
      label: "Conversion Rate to {{ event_1._value }}"
      url: "
      {% assign vis_config = '{
      \"type\":\"looker_column\",
      \"y_axes\":[{\"maxValue\":1}]
      }' %}
      https://cengage.looker.com/explore/event_analysis/conversion_analysis?
      vis_config={{ vis_config | encode_uri }}
      &f[conversion_analysis.initial_date_range_filter]={{_filters['cohort_date_range_filter'] | url_encode}}
      &f[conversion_analysis.time_period]=1
      &f[conversion_analysis.number_period]=5
      &f[conversion_analysis.initial_events_filter]={{start_events._value | url_encode}}
      &f[conversion_analysis.conversion_events_filter]={{event_1._value | url_encode}}
      &fields=conversion_analysis.conversion_rate,conversion_analysis.conversion_period"
    }

    link: {
      label: "Conversion Rate to {{ event_2._value }}"
      url: "
      {% assign vis_config = '{
      \"type\":\"looker_column\",
      \"y_axes\":[{\"maxValue\":1}]
      }' %}
      https://cengage.looker.com/explore/event_analysis/conversion_analysis?
      vis_config={{ vis_config | encode_uri }}
      &f[conversion_analysis.initial_date_range_filter]={{_filters['cohort_date_range_filter'] | url_encode}}
      &f[conversion_analysis.time_period]=1
      &f[conversion_analysis.number_period]=5
      &f[conversion_analysis.initial_events_filter]={{start_events._value | url_encode}}
      &f[conversion_analysis.conversion_events_filter]={{event_2._value | url_encode}}
      &fields=conversion_analysis.conversion_rate,conversion_analysis.conversion_period"
    }

    link: {
      label: "Conversion Rate to {{ event_3._value }}"
      url: "
      {% assign vis_config = '{
      \"type\":\"looker_column\",
      \"y_axes\":[{\"maxValue\":1}]
      }' %}
      https://cengage.looker.com/explore/event_analysis/conversion_analysis?
      vis_config={{ vis_config | encode_uri }}
      &f[conversion_analysis.initial_date_range_filter]={{_filters['cohort_date_range_filter'] | url_encode}}
      &f[conversion_analysis.time_period]=1
      &f[conversion_analysis.number_period]=5
      &f[conversion_analysis.initial_events_filter]={{start_events._value | url_encode}}
      &f[conversion_analysis.conversion_events_filter]={{event_3._value | url_encode}}
      &fields=conversion_analysis.conversion_rate,conversion_analysis.conversion_period"
    }
    link: {
      label: "Conversion Rate to {{ event_4._value }}"
      url: "
      {% assign vis_config = '{
      \"type\":\"looker_column\",
      \"y_axes\":[{\"maxValue\":1}]
      }' %}
      https://cengage.looker.com/explore/event_analysis/conversion_analysis?
      vis_config={{ vis_config | encode_uri }}
      &f[conversion_analysis.initial_date_range_filter]={{_filters['cohort_date_range_filter'] | url_encode}}
      &f[conversion_analysis.time_period]=1
      &f[conversion_analysis.number_period]=5
      &f[conversion_analysis.initial_events_filter]={{start_events._value | url_encode}}
      &f[conversion_analysis.conversion_events_filter]={{event_4._value | url_encode}}
      &fields=conversion_analysis.conversion_rate,conversion_analysis.conversion_period"
    }

    link: {
      label: "Conversion Rate to {{ event_5._value }}"
      url: "
      {% assign vis_config = '{
      \"type\":\"looker_column\",
      \"y_axes\":[{\"maxValue\":1}]
      }' %}
      https://cengage.looker.com/explore/event_analysis/conversion_analysis?
      vis_config={{ vis_config | encode_uri }}
      &f[conversion_analysis.initial_date_range_filter]={{_filters['cohort_date_range_filter'] | url_encode}}
      &f[conversion_analysis.time_period]=1
      &f[conversion_analysis.number_period]=5
      &f[conversion_analysis.initial_events_filter]={{start_events._value | url_encode}}
      &f[conversion_analysis.conversion_events_filter]={{event_5._value | url_encode}}
      &fields=conversion_analysis.conversion_rate,conversion_analysis.conversion_period"
    }

  }

}
