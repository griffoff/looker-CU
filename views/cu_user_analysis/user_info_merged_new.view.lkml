view: user_info_merged_new {
  derived_table: {
    sql:
      select distinct
        hu.uid
        , su.*
        , coalesce(su.linked_guid,hu.uid) as merged_guid
      from prod.datavault.hub_user hu
      inner join prod.datavault.sat_user_v2 su on su.hub_user_key = hu.hub_user_key and su._latest
    ;;
    persist_for: "8 hours"
  }

dimension: hub_user_key {hidden:yes primary_key:yes}
dimension: merged_guid {}
dimension: user_sso_guid {
  sql: ${TABLE}.uid ;;
}

}
