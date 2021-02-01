explore: institution_info {hidden:yes group_label:"Institution Info"}
view: institution_info {
  derived_table: {
    sql:
      select distinct
        hi.institution_id
        , sis.name
        , sis.type
        , sis.iso_country
        , sc.country_name
        , sc.financial_sales_region
      from prod.datavault.hub_institution hi
      inner join prod.DATAVAULT.SAT_INSTITUTION_SAWS sis on sis.hub_institution_key = hi.hub_institution_key and sis._LATEST
      inner join prod.DATAVAULT.LINK_INSTITUTION_COUNTRY lic on lic.HUB_INSTITUTION_KEY = hi.HUB_INSTITUTION_KEY
      inner join prod.DATAVAULT.SAT_INSTITUTION_COUNTRY_EFFECTIVITY sice on sice.LINK_INSTITUTION_COUNTRY_KEY = lic.LINK_INSTITUTION_COUNTRY_KEY and sice._EFFECTIVE
      inner join prod.datavault.SAT_COUNTRY sc on sc.HUB_COUNTRY_KEY = lic.HUB_COUNTRY_KEY and sc._LATEST

    ;;
    persist_for: "8 hours"
  }

  dimension: institution_id  {primary_key:yes group_label:"Institution Info"}
  dimension: name {label:"Institution Name" group_label:"Institution Info"}
  dimension: type {label:"Institution Type" group_label:"Institution Info"}
  dimension: iso_country {label:"Institution Country Code" group_label:"Institution Info"}
  dimension: country_name {label:"Institution Country Name" group_label:"Institution Info"}
  dimension: financial_sales_region {label:"Institution Financial Sales Region" group_label:"Institution Info"}

  measure: count {
    type: count
    label: "# Institutions"
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      institution_id,
      name,
      type,
      iso_country,
      country_name,
      financial_sales_region
    ]
  }

}
