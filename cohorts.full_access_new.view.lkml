include: "cohorts.base.view"

view: cohorts_full_access_new {

  extends: [cohorts_base_events_binary]



  parameter: events_to_include {
    default_value: "Subscription: Read Only To Full Access, Subscription: Trial Converted To Subscription, Subscription: Provisional Locker To Full Access, Subscription: Subscription Without Trial, Subscription: Subscription Reinstated"
    hidden: yes
  }

  dimension: current {group_label: "Full Access New"}

  dimension: minus_1 {group_label: "Full Access New"}

  dimension: minus_2 {group_label: "Full Access New"}

  dimension: minus_3 {group_label: "Full Access New"}

  dimension: minus_4 {group_label: "Full Access New"}


  dimension: renewed_flag {
    type: yesno
    sql: (${cohorts_full_access_50.minus_1} = 'Yes') AND (${cohorts_full_access_new.current} = 1)
      ;;
    hidden: yes
  }

  measure: renewals {
    type: number
    sql: COUNT( DISTINCT CASE WHEN (${cohorts_full_access_50.minus_1} = 'Yes') AND (${cohorts_full_access_new.current} = 1) THEN ${learner_profile.user_sso_guid} END )
      ;;
    hidden: yes
  }

  measure: renewals_end_1 {
    group_label: "Renewal rates"
    type: number
    sql:
      COUNT ( DISTINCT
        CASE WHEN
                (${cohorts_full_access_ended.minus_1} = 'Yes' OR ${cohorts_full_access_ended.minus_2} = 'Yes' OR  ${cohorts_full_access_ended.current} = 'Yes')
                AND ${cohorts_full_access_new.current} = 1
            THEN ${learner_profile.user_sso_guid} END
            )
      ;;
    hidden: yes
  }

  measure: renewals_end_2 {
    group_label: "Renewal rates"
    type: number
    sql:
      COUNT ( DISTINCT
        CASE WHEN
                (${cohorts_full_access_ended.minus_1} = 'Yes')
                AND (${cohorts_full_access_new.current} = 1)
            THEN ${learner_profile.user_sso_guid} END
            )
      ;;
    hidden: yes
  }

  measure: previous_two_term_fa_ends {
    group_label: "Renewal rates"
    type: number
    sql: COUNT( DISTINCT CASE WHEN (${cohorts_full_access_ended.minus_1} = 'Yes' OR ${cohorts_full_access_ended.minus_2} = 'Yes') THEN ${learner_profile.user_sso_guid} END )
      ;;
    hidden: yes
  }



  measure: previous_term_fa_ends {
    group_label: "Renewal rates"
    type: number
    sql: COUNT( DISTINCT CASE WHEN ${cohorts_full_access_ended.minus_1} = 'Yes' THEN ${learner_profile.user_sso_guid} END )
      ;;
    hidden: yes
  }

  measure: renewal_rate_ends_1 {
    group_label: "Renewal rates"
    label: "Renewal rate 2"
    description: "(# of users that have a new subscription in the current term and had a subscription end in the priorterm + # users with current term extensions) / # of users with subscriptions ending in the previous term"
    type: number
    sql: (${renewals_end_1} + ${current_extensions}) / ${previous_term_fa_ends} ;;
    value_format_name: "percent_2"
    hidden: no
  }

  measure: renewal_rate_ends_2 {
    group_label: "Renewal rates"
    type: number
    sql: (${renewals_end_2} + ${current_extensions}) / ${previous_two_term_fa_ends} ;;
    value_format_name: "percent_2"
    hidden: yes
  }

  measure: previous_full_access {
    type: number
    sql: COUNT( DISTINCT CASE WHEN (${cohorts_full_access_50.minus_1} = 'Yes') THEN ${learner_profile.user_sso_guid} END )
      ;;
    hidden: yes
  }

  measure: current_extensions {
    type: number
    sql: COUNT( DISTINCT CASE WHEN (${cohorts_extended.current} = 1) THEN ${learner_profile.user_sso_guid} END )
      ;;
    hidden: yes
  }

  measure: renewal_rate {
    group_label: "Renewal rates"
    label: "Renewal rate"
    description: "# of users with a subscription in the previous term and a new subscription in the current term / # of users with a subscription in thep revious term"
    type: number
    value_format_name: "percent_2"
    sql: ${renewals} / ${previous_full_access} ;;
    hidden: no
  }

  measure: renewal_rate_extensions {
    group_label: "Renewal rates"
    type: number
    sql: (${renewals} + ${current_extensions}) / ${previous_full_access} ;;
    value_format_name: "percent_2"
    hidden: yes
  }

}
