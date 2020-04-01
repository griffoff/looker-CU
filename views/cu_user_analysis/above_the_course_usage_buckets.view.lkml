explore: above_the_course_usage_buckets {}
view: above_the_course_usage_buckets {

  derived_table: {
    explore_source: session_analysis {
      column: user_sso_guid { field: learner_profile.user_sso_guid }
#       column: event_name { field: all_events.event_name }
#       column: count { field: all_events.count }
      column: above_the_courses { field: all_events.above_the_courses }
      filters: {
        field: merged_cu_user_info.internal_user_flag
        value: "No"
      }
      filters: {
        field: all_events.local_date
        value: "after 2020/01/01"
      }
      filters: {
        field: all_events.event_subscription_state
        value: "Full Access"
      }
      filters: {
        field: dim_institution.HED_filter
        value: "Yes"
      }
    }
  }


  dimension: user_sso_guid {
    hidden:  no
    label: "Learner Profile User SSO GUID"
    description: "Primary Guid, after mapping and merging from shadow guids"
  }
#   dimension: event_name {
#     label: "Events Event name"
#     description: "The lowest level in hierarchy of event classification below event action.
#     Can be asscoaited with describing a user action in plain english i.e. 'Buy Now Button Click'
#     n.b. These names come from a mapping table to make them friendlier than the raw names from the event stream.
#     If no mapping is found the upper case raw name is used with asterisks to signify the difference - e.g. ** EVENT TYPE: EVENT ACTION **
#     "
#   }
#   dimension: count {
#     label: "Events # Events"
#     description: "Measure for counting events (drill fields)"
#     type: number
#   }
#


  dimension: above_the_courses {
    view_label: "Events"
    label: "# of ATC usages - no ebook"
    description: "Number of times an Above The Course event occurred for a given user"
    type: number
  }

  dimension: above_the_course_tiered {
    label: "ATC Usage buckets"
    view_label: "Events"
    type: tier
    style: integer
    tiers: [0,2,6]
    sql: ${above_the_courses};;
    description: "Buckets of Number of times an Above The Course event occurred for a given user"
  }

  measure: dist_guids {
    hidden:  yes
    label: "# Users"
    type: count_distinct
    sql: ${user_sso_guid} ;;
  }
}
