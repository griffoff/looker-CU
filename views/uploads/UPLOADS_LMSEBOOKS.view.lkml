explore: uploads_lmsebooks {}
view: uploads_lmsebooks {
  derived_table: {
    sql:
      select distinct
      coalesce(su.LINKED_GUID, hu.UID) as merged_guid
        , ss.SUBSCRIPTION_PLAN_ID
        , ss.SUBSCRIPTION_STATE
        , ss.SUBSCRIPTION_START
        , ss.CANCELLED_TIME
        , ss.SUBSCRIPTION_END
        , e.created_on between ss.SUBSCRIPTION_START and coalesce(ss.CANCELLED_TIME, ss.SUBSCRIPTION_END) as subscriber_at_provisioning
        , e.created_on between dateadd(d, -7, ss.SUBSCRIPTION_START) and ss.SUBSCRIPTION_START as subscriber_after_provisioning
        , e.*
      from "UPLOADS"."LMSEBOOKS"."LMSEBOOKS" e
      left join prod.datavault.hub_user hu on hu.uid = e.guid
      left join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
      left join (
        select ss.*
        , coalesce(su.LINKED_GUID, hu.UID) as merged_guid
        from prod.DATAVAULT.SAT_SUBSCRIPTION_SAP ss
        left join prod.datavault.hub_user hu on hu.uid = ss.current_guid
        left join prod.DATAVAULT.SAT_USER_V2 su on su.HUB_USER_KEY = hu.HUB_USER_KEY and su._LATEST
        where ss.SUBSCRIPTION_PLAN_ID in ('CU-ETextBook-120','Full-Access-120','Full-Access-365','Full-Access-730') and ss._LATEST
      ) ss on ss.merged_guid = coalesce(su.LINKED_GUID, hu.UID)
          and e.created_on between iff(ss.CANCELLED_TIME is null, dateadd(d, -7, ss.SUBSCRIPTION_START), ss.subscription_start) and coalesce(ss.CANCELLED_TIME, ss.SUBSCRIPTION_END)
    ;;
    persist_for: "8 hours"
  }

  dimension: merged_guid {}
  dimension: subscription_plan_id {}
  dimension: subscription_state {}
  dimension: subscription_start {type:date_time}
  dimension: subscription_end {type:date_time}
  dimension: cancelled_time {type:date_time}
  dimension: subscriber_at_provisioning {type:yesno}
  dimension: subscriber_after_provisioning {type:yesno}

  dimension: created_on {type:date_time}
  dimension: guid {}
  dimension: institution_id {}
  dimension: institution_name {}
  dimension: iso_country_code {}
  dimension: section_id {}
  dimension: section_name {}
  dimension: _fivetran_synced {type:date_time}

  dimension: ebook_provision_subscription_status {
    sql: case
          when ${subscriber_after_provisioning} then 'Subscribed within 7 Days of ebook provision'
          when ${subscriber_at_provisioning} then 'Active subscription at time of ebook provision'
          else 'No subscription'
        end ;;
  }

  measure: number_users {
    type: count_distinct
    sql: ${merged_guid} ;;
    label: "# Users"
  }



}
