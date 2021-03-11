explore:  cu_savings_fy19_fy20{hidden:yes}
view: cu_savings_fy19_fy20 {
  sql_table_name: strategy.spr_review_fy20.savings_cann_seasons ;;

  dimension: takeopp_season {label:"Season"}

  dimension:  takeopp_fiscal_year {label:"Fiscal Year"}

  measure: savings_incl_partners {
    label: "$ Saved From CU"
    type: sum
    value_format_name: usd
    }
}
