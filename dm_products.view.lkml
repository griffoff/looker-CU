view: dm_products {
  sql_table_name: DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_PRODUCTS ;;

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension: acquisition_ed_cd {
    type: string
    sql: ${TABLE}."ACQUISITION_ED_CD" ;;
  }

  dimension: acquisition_ed_de {
    type: string
    sql: ${TABLE}."ACQUISITION_ED_DE" ;;
  }

  dimension_group: added_dt {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ADDED_DT" ;;
  }

  dimension: advantage_hybrid_cd {
    type: string
    sql: ${TABLE}."ADVANTAGE_HYBRID_CD" ;;
  }

  dimension: advantage_hybrid_de {
    type: string
    sql: ${TABLE}."ADVANTAGE_HYBRID_DE" ;;
  }

  dimension: all_authors_nm {
    type: string
    sql: ${TABLE}."ALL_AUTHORS_NM" ;;
  }

  dimension: audience_cd {
    type: string
    sql: ${TABLE}."AUDIENCE_CD" ;;
  }

  dimension: audience_de {
    type: string
    sql: ${TABLE}."AUDIENCE_DE" ;;
  }

  dimension: available_dt {
    type: string
    sql: ${TABLE}."AVAILABLE_DT" ;;
  }

  dimension: back_file_year_cd {
    type: string
    sql: ${TABLE}."BACK_FILE_YEAR_CD" ;;
  }

  dimension: back_file_year_de {
    type: string
    sql: ${TABLE}."BACK_FILE_YEAR_DE" ;;
  }

  dimension: backorder_flg {
    type: string
    sql: ${TABLE}."BACKORDER_FLG" ;;
  }

  dimension: bind_cd {
    type: string
    sql: ${TABLE}."BIND_CD" ;;
  }

  dimension: bind_cd_de {
    type: string
    sql: ${TABLE}."BIND_CD_DE" ;;
  }

  dimension: brief_concise_cd {
    type: string
    sql: ${TABLE}."BRIEF_CONCISE_CD" ;;
  }

  dimension: brief_concise_de {
    type: string
    sql: ${TABLE}."BRIEF_CONCISE_DE" ;;
  }

  dimension: bundle_msg_cd {
    type: string
    sql: ${TABLE}."BUNDLE_MSG_CD" ;;
  }

  dimension: bundle_msg_de {
    type: string
    sql: ${TABLE}."BUNDLE_MSG_DE" ;;
  }

  dimension: bundle_price {
    type: number
    sql: ${TABLE}."BUNDLE_PRICE" ;;
  }

  dimension: business_unit_cd {
    type: number
    sql: ${TABLE}."BUSINESS_UNIT_CD" ;;
  }

  dimension: business_unit_de {
    type: string
    sql: ${TABLE}."BUSINESS_UNIT_DE" ;;
  }

  dimension: changed_dt {
    type: string
    sql: ${TABLE}."CHANGED_DT" ;;
  }

  dimension: copyright_yr {
    type: number
    sql: ${TABLE}."COPYRIGHT_YR" ;;
  }

  dimension: country_of_origin_cd {
    type: string
    sql: ${TABLE}."COUNTRY_OF_ORIGIN_CD" ;;
  }

  dimension: country_of_origin_de {
    type: string
    sql: ${TABLE}."COUNTRY_OF_ORIGIN_DE" ;;
  }

  dimension: course_cd {
    type: string
    sql: ${TABLE}."COURSE_CD" ;;
  }

  dimension: course_de {
    type: string
    sql: ${TABLE}."COURSE_DE" ;;
  }

  dimension: custom_pub_flg {
    type: string
    sql: ${TABLE}."CUSTOM_PUB_FLG" ;;
  }

  dimension: development_fee {
    type: string
    sql: ${TABLE}."DEVELOPMENT_FEE" ;;
  }

  dimension: developmental_ed_cd {
    type: string
    sql: ${TABLE}."DEVELOPMENTAL_ED_CD" ;;
  }

  dimension: developmental_ed_de {
    type: string
    sql: ${TABLE}."DEVELOPMENTAL_ED_DE" ;;
  }

  dimension: digital_vad_flg {
    type: string
    sql: ${TABLE}."DIGITAL_VAD_FLG" ;;
  }

  dimension: discipline_cd {
    type: string
    sql: ${TABLE}."DISCIPLINE_CD" ;;
  }

  dimension: discipline_de {
    type: string
    sql: ${TABLE}."DISCIPLINE_DE" ;;
  }

  dimension: division_cd {
    type: string
    sql: ${TABLE}."DIVISION_CD" ;;
  }

  dimension: division_de {
    type: string
    sql: ${TABLE}."DIVISION_DE" ;;
  }

  dimension: e_product_cd {
    type: string
    sql: ${TABLE}."E_PRODUCT_CD" ;;
  }

  dimension: e_product_de {
    type: string
    sql: ${TABLE}."E_PRODUCT_DE" ;;
  }

  dimension: edition {
    type: number
    sql: ${TABLE}."EDITION" ;;
  }

  dimension: edition_cd {
    type: string
    sql: ${TABLE}."EDITION_CD" ;;
  }

  dimension: edition_de {
    type: string
    sql: ${TABLE}."EDITION_DE" ;;
  }

  dimension: gl_category_cd {
    type: string
    sql: ${TABLE}."GL_CATEGORY_CD" ;;
  }

  dimension: gl_category_de {
    type: string
    sql: ${TABLE}."GL_CATEGORY_DE" ;;
  }

  dimension: grade_level_beg {
    type: string
    sql: ${TABLE}."GRADE_LEVEL_BEG" ;;
  }

  dimension: grade_level_end {
    type: string
    sql: ${TABLE}."GRADE_LEVEL_END" ;;
  }

  dimension: heao_cd {
    type: number
    sql: ${TABLE}."HEAO_CD" ;;
  }

  dimension: heao_de {
    type: string
    sql: ${TABLE}."HEAO_DE" ;;
  }

  dimension: hed_discipline_nm {
    type: string
    sql: ${TABLE}."HED_DISCIPLINE_NM" ;;
  }

  dimension: hmh_ap_cd {
    type: string
    sql: ${TABLE}."HMH_AP_CD" ;;
  }

  dimension: hmh_ap_de {
    type: string
    sql: ${TABLE}."HMH_AP_DE" ;;
  }

  dimension: hpl_override_flg {
    type: string
    sql: ${TABLE}."HPL_OVERRIDE_FLG" ;;
  }

  dimension: hpl_rung_cd {
    type: string
    sql: ${TABLE}."HPL_RUNG_CD" ;;
  }

  dimension: hpl_rung_de {
    type: string
    sql: ${TABLE}."HPL_RUNG_DE" ;;
  }

  dimension: imprint_cd {
    type: string
    sql: ${TABLE}."IMPRINT_CD" ;;
  }

  dimension: imprint_de {
    type: string
    sql: ${TABLE}."IMPRINT_DE" ;;
  }

  dimension: indigenous_flg {
    type: string
    sql: ${TABLE}."INDIGENOUS_FLG" ;;
  }

  dimension: international_price_rule_cd {
    type: string
    sql: ${TABLE}."INTERNATIONAL_PRICE_RULE_CD" ;;
  }

  dimension: international_price_rule_de {
    type: string
    sql: ${TABLE}."INTERNATIONAL_PRICE_RULE_DE" ;;
  }

  dimension: inventory_tracking_cd {
    type: string
    sql: ${TABLE}."INVENTORY_TRACKING_CD" ;;
  }

  dimension: inventory_tracking_de {
    type: string
    sql: ${TABLE}."INVENTORY_TRACKING_DE" ;;
  }

  dimension: isbn_10 {
    type: string
    sql: ${TABLE}."ISBN_10" ;;
  }

  dimension: isbn_13 {
    type: string
    sql: ${TABLE}."ISBN_13" ;;
  }

  dimension: item_cd {
    type: string
    sql: ${TABLE}."ITEM_CD" ;;
  }

  dimension: item_de {
    type: string
    sql: ${TABLE}."ITEM_DE" ;;
  }

  dimension_group: item_effective_dt {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ITEM_EFFECTIVE_DT" ;;
  }

  dimension: item_flash_msg_cd {
    type: string
    sql: ${TABLE}."ITEM_FLASH_MSG_CD" ;;
  }

  dimension: item_flash_msg_de {
    type: string
    sql: ${TABLE}."ITEM_FLASH_MSG_DE" ;;
  }

  dimension: kit_component_de {
    type: string
    sql: ${TABLE}."KIT_COMPONENT_DE" ;;
  }

  dimension: kit_component_flg {
    type: string
    sql: ${TABLE}."KIT_COMPONENT_FLG" ;;
  }

  dimension: kit_special_handling_cd {
    type: string
    sql: ${TABLE}."KIT_SPECIAL_HANDLING_CD" ;;
  }

  dimension: kit_special_handling_de {
    type: string
    sql: ${TABLE}."KIT_SPECIAL_HANDLING_DE" ;;
  }

  dimension: language_cd {
    type: string
    sql: ${TABLE}."LANGUAGE_CD" ;;
  }

  dimension: language_de {
    type: string
    sql: ${TABLE}."LANGUAGE_DE" ;;
  }

  dimension: last_allow_rtn_dt {
    type: string
    sql: ${TABLE}."LAST_ALLOW_RTN_DT" ;;
  }

  dimension: line_type_cd {
    type: string
    sql: ${TABLE}."LINE_TYPE_CD" ;;
  }

  dimension: line_type_de {
    type: string
    sql: ${TABLE}."LINE_TYPE_DE" ;;
  }

  dimension: list_price {
    type: number
    sql: ${TABLE}."LIST_PRICE" ;;
  }

  dimension: lst_transfer_cd {
    type: string
    sql: ${TABLE}."LST_TRANSFER_CD" ;;
  }

  dimension: lst_transfer_de {
    type: string
    sql: ${TABLE}."LST_TRANSFER_DE" ;;
  }

  dimension: make_to_order_flg {
    type: string
    sql: ${TABLE}."MAKE_TO_ORDER_FLG" ;;
  }

  dimension: management_entity_cd {
    type: string
    sql: ${TABLE}."MANAGEMENT_ENTITY_CD" ;;
  }

  dimension: management_entity_de {
    type: string
    sql: ${TABLE}."MANAGEMENT_ENTITY_DE" ;;
  }

  dimension: management_group_cd {
    type: string
    sql: ${TABLE}."MANAGEMENT_GROUP_CD" ;;
  }

  dimension: management_group_de {
    type: string
    sql: ${TABLE}."MANAGEMENT_GROUP_DE" ;;
  }

  dimension: manufacturing_cd {
    type: string
    sql: ${TABLE}."MANUFACTURING_CD" ;;
  }

  dimension: manufacturing_de {
    type: string
    sql: ${TABLE}."MANUFACTURING_DE" ;;
  }

  dimension: manufacturing_specs_cd {
    type: string
    sql: ${TABLE}."MANUFACTURING_SPECS_CD" ;;
  }

  dimension: manufacturing_specs_de {
    type: string
    sql: ${TABLE}."MANUFACTURING_SPECS_DE" ;;
  }

  dimension: market_group {
    type: string
    sql: ${TABLE}."MARKET_GROUP" ;;
  }

  dimension: marketing_mgr_cd {
    type: string
    sql: ${TABLE}."MARKETING_MGR_CD" ;;
  }

  dimension: marketing_mgr_de {
    type: string
    sql: ${TABLE}."MARKETING_MGR_DE" ;;
  }

  dimension: md_5_chksum_num {
    type: string
    sql: ${TABLE}."MD_5_CHKSUM_NUM" ;;
  }

  dimension: media_type_cd {
    type: string
    sql: ${TABLE}."MEDIA_TYPE_CD" ;;
  }

  dimension: media_type_de {
    type: string
    sql: ${TABLE}."MEDIA_TYPE_DE" ;;
  }

  dimension: nat_geo_royalty_cd {
    type: string
    sql: ${TABLE}."NAT_GEO_ROYALTY_CD" ;;
  }

  dimension: nat_geo_royalty_de {
    type: string
    sql: ${TABLE}."NAT_GEO_ROYALTY_DE" ;;
  }

  dimension: net_price {
    type: number
    sql: ${TABLE}."NET_PRICE" ;;
  }

  dimension: next_edition_ptr {
    type: number
    sql: ${TABLE}."NEXT_EDITION_PTR" ;;
  }

  dimension: online_catalog_cd {
    type: string
    sql: ${TABLE}."ONLINE_CATALOG_CD" ;;
  }

  dimension: online_catalog_de {
    type: string
    sql: ${TABLE}."ONLINE_CATALOG_DE" ;;
  }

  dimension: online_catalog_kit_comp_cd {
    type: string
    sql: ${TABLE}."ONLINE_CATALOG_KIT_COMP_CD" ;;
  }

  dimension: online_catalog_kit_comp_de {
    type: string
    sql: ${TABLE}."ONLINE_CATALOG_KIT_COMP_DE" ;;
  }

  dimension: online_series_cd {
    type: string
    sql: ${TABLE}."ONLINE_SERIES_CD" ;;
  }

  dimension: online_series_de {
    type: string
    sql: ${TABLE}."ONLINE_SERIES_DE" ;;
  }

  dimension: original_works_isbn_ptr {
    type: number
    sql: ${TABLE}."ORIGINAL_WORKS_ISBN_PTR" ;;
  }

  dimension_group: out_of_print_dt {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."OUT_OF_PRINT_DT" ;;
  }

  dimension: outsource_flg {
    type: string
    sql: ${TABLE}."OUTSOURCE_FLG" ;;
  }

  dimension: permission_rights_cd {
    type: string
    sql: ${TABLE}."PERMISSION_RIGHTS_CD" ;;
  }

  dimension: permission_rights_de {
    type: string
    sql: ${TABLE}."PERMISSION_RIGHTS_DE" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: pre_pub_cost_flg {
    type: string
    sql: ${TABLE}."PRE_PUB_COST_FLG" ;;
  }

  dimension: prev_edition_ptr {
    type: number
    sql: ${TABLE}."PREV_EDITION_PTR" ;;
  }

  dimension: prev_list_price {
    type: number
    sql: ${TABLE}."PREV_LIST_PRICE" ;;
  }

  dimension_group: prev_net_prc_chg_dt {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PREV_NET_PRC_CHG_DT" ;;
  }

  dimension: prev_net_price {
    type: number
    sql: ${TABLE}."PREV_NET_PRICE" ;;
  }

  dimension: price_rule_cd {
    type: string
    sql: ${TABLE}."PRICE_RULE_CD" ;;
  }

  dimension: price_rule_de {
    type: string
    sql: ${TABLE}."PRICE_RULE_DE" ;;
  }

  dimension: primary_flg {
    type: number
    sql: ${TABLE}."PRIMARY_FLG" ;;
  }

  dimension: print_digital_config_cd {
    type: number
    sql: ${TABLE}."PRINT_DIGITAL_CONFIG_CD" ;;
  }

  dimension: print_digital_config_de {
    type: string
    sql: ${TABLE}."PRINT_DIGITAL_CONFIG_DE" ;;
  }

  dimension: print_digital_finance_cd {
    type: number
    sql: ${TABLE}."PRINT_DIGITAL_FINANCE_CD" ;;
  }

  dimension: print_digital_finance_de {
    type: string
    sql: ${TABLE}."PRINT_DIGITAL_FINANCE_DE" ;;
  }

  dimension: print_digital_summary {
    type: string
    sql: ${TABLE}."PRINT_DIGITAL_SUMMARY" ;;
  }

  dimension: print_run {
    type: string
    sql: ${TABLE}."PRINT_RUN" ;;
  }

  dimension: prior_publ_cd {
    type: string
    sql: ${TABLE}."PRIOR_PUBL_CD" ;;
  }

  dimension: prior_publ_de {
    type: string
    sql: ${TABLE}."PRIOR_PUBL_DE" ;;
  }

  dimension: prod_code_1_cd {
    type: string
    sql: ${TABLE}."PROD_CODE_1_CD" ;;
  }

  dimension: prod_code_1_de {
    type: string
    sql: ${TABLE}."PROD_CODE_1_DE" ;;
  }

  dimension: prod_code_2_cd {
    type: string
    sql: ${TABLE}."PROD_CODE_2_CD" ;;
  }

  dimension: prod_code_2_de {
    type: string
    sql: ${TABLE}."PROD_CODE_2_DE" ;;
  }

  dimension: prod_code_3_cd {
    type: string
    sql: ${TABLE}."PROD_CODE_3_CD" ;;
  }

  dimension: prod_code_3_de {
    type: string
    sql: ${TABLE}."PROD_CODE_3_DE" ;;
  }

  dimension: prod_family_cd {
    type: string
    sql: ${TABLE}."PROD_FAMILY_CD" ;;
  }

  dimension: prod_family_de {
    type: string
    sql: ${TABLE}."PROD_FAMILY_DE" ;;
  }

  dimension: prod_line_media_cd {
    type: number
    sql: ${TABLE}."PROD_LINE_MEDIA_CD" ;;
  }

  dimension: prod_line_media_de {
    type: string
    sql: ${TABLE}."PROD_LINE_MEDIA_DE" ;;
  }

  dimension: product_market_segment_cd {
    type: string
    sql: ${TABLE}."PRODUCT_MARKET_SEGMENT_CD" ;;
  }

  dimension: product_market_segment_de {
    type: string
    sql: ${TABLE}."PRODUCT_MARKET_SEGMENT_DE" ;;
  }

  dimension: product_skey {
    type: number
    sql: ${TABLE}."PRODUCT_SKEY" ;;
  }

  dimension: production_ed_cd {
    type: string
    sql: ${TABLE}."PRODUCTION_ED_CD" ;;
  }

  dimension: production_ed_de {
    type: string
    sql: ${TABLE}."PRODUCTION_ED_DE" ;;
  }

  dimension: prproduct_type_de {
    type: string
    sql: ${TABLE}."PRPRODUCT_TYPE_DE" ;;
  }

  dimension: prt_ebk_cross_ref_ptr {
    type: number
    sql: ${TABLE}."PRT_EBK_CROSS_REF_PTR" ;;
  }

  dimension: pt_course {
    type: string
    sql: ${TABLE}."PT_COURSE" ;;
  }

  dimension: pt_course_area {
    type: string
    sql: ${TABLE}."PT_COURSE_AREA" ;;
  }

  dimension: pt_discipline {
    type: string
    sql: ${TABLE}."PT_DISCIPLINE" ;;
  }

  dimension: pub_defined_cd {
    type: string
    sql: ${TABLE}."PUB_DEFINED_CD" ;;
  }

  dimension: pub_defined_de {
    type: string
    sql: ${TABLE}."PUB_DEFINED_DE" ;;
  }

  dimension: pub_series_cd {
    type: string
    sql: ${TABLE}."PUB_SERIES_CD" ;;
  }

  dimension: pub_series_de {
    type: string
    sql: ${TABLE}."PUB_SERIES_DE" ;;
  }

  dimension_group: publ_dt {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PUBL_DT" ;;
  }

  dimension: publ_grp_cd {
    type: string
    sql: ${TABLE}."PUBL_GRP_CD" ;;
  }

  dimension: publ_grp_de {
    type: string
    sql: ${TABLE}."PUBL_GRP_DE" ;;
  }

  dimension: pubnet_flg {
    type: string
    sql: ${TABLE}."PUBNET_FLG" ;;
  }

  dimension: rental_flg {
    type: string
    sql: ${TABLE}."RENTAL_FLG" ;;
  }

  dimension: reprice_rule_cd {
    type: string
    sql: ${TABLE}."REPRICE_RULE_CD" ;;
  }

  dimension: reprice_rule_de {
    type: string
    sql: ${TABLE}."REPRICE_RULE_DE" ;;
  }

  dimension: returnable_flg {
    type: string
    sql: ${TABLE}."RETURNABLE_FLG" ;;
  }

  dimension: returns_pct_allowed_cd {
    type: string
    sql: ${TABLE}."RETURNS_PCT_ALLOWED_CD" ;;
  }

  dimension: returns_pct_allowed_de {
    type: string
    sql: ${TABLE}."RETURNS_PCT_ALLOWED_DE" ;;
  }

  dimension: rights_cd {
    type: number
    sql: ${TABLE}."RIGHTS_CD" ;;
  }

  dimension: rights_de {
    type: string
    sql: ${TABLE}."RIGHTS_DE" ;;
  }

  dimension: royalty_allocation_digital_cd {
    type: string
    sql: ${TABLE}."ROYALTY_ALLOCATION_DIGITAL_CD" ;;
  }

  dimension: royalty_allocation_digital_de {
    type: string
    sql: ${TABLE}."ROYALTY_ALLOCATION_DIGITAL_DE" ;;
  }

  dimension: royalty_flg {
    type: string
    sql: ${TABLE}."ROYALTY_FLG" ;;
  }

  dimension: royalty_usage_product_cd {
    type: string
    sql: ${TABLE}."ROYALTY_USAGE_PRODUCT_CD" ;;
  }

  dimension: royalty_usage_product_de {
    type: string
    sql: ${TABLE}."ROYALTY_USAGE_PRODUCT_DE" ;;
  }

  dimension: royalty_usage_product_media {
    type: string
    sql: ${TABLE}."ROYALTY_USAGE_PRODUCT_MEDIA" ;;
  }

  dimension: royalty_usage_product_media_de {
    type: string
    sql: ${TABLE}."ROYALTY_USAGE_PRODUCT_MEDIA_DE" ;;
  }

  dimension: safety_stock {
    type: number
    sql: ${TABLE}."SAFETY_STOCK" ;;
  }

  dimension: salable_flg {
    type: string
    sql: ${TABLE}."SALABLE_FLG" ;;
  }

  dimension: sampling_restrictions_cd {
    type: string
    sql: ${TABLE}."SAMPLING_RESTRICTIONS_CD" ;;
  }

  dimension: sampling_restrictions_de {
    type: string
    sql: ${TABLE}."SAMPLING_RESTRICTIONS_DE" ;;
  }

  dimension: school_cd {
    type: string
    sql: ${TABLE}."SCHOOL_CD" ;;
  }

  dimension: school_de {
    type: string
    sql: ${TABLE}."SCHOOL_DE" ;;
  }

  dimension: short_item_no {
    type: number
    sql: ${TABLE}."SHORT_ITEM_NO" ;;
  }

  dimension: short_title {
    type: string
    sql: ${TABLE}."SHORT_TITLE" ;;
  }

  dimension: stock_status_cd {
    type: string
    sql: ${TABLE}."STOCK_STATUS_CD" ;;
  }

  dimension_group: stock_status_chng_dt {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."STOCK_STATUS_CHNG_DT" ;;
  }

  dimension: stock_status_chng_dt_dskey {
    type: number
    sql: ${TABLE}."STOCK_STATUS_CHNG_DT_DSKEY" ;;
  }

  dimension: stock_status_de {
    type: string
    sql: ${TABLE}."STOCK_STATUS_DE" ;;
  }

  dimension: stocking_type_cd {
    type: string
    sql: ${TABLE}."STOCKING_TYPE_CD" ;;
  }

  dimension: stocking_type_de {
    type: string
    sql: ${TABLE}."STOCKING_TYPE_DE" ;;
  }

  dimension: sub_matter_maj_cd {
    type: string
    sql: ${TABLE}."SUB_MATTER_MAJ_CD" ;;
  }

  dimension: sub_matter_maj_de {
    type: string
    sql: ${TABLE}."SUB_MATTER_MAJ_DE" ;;
  }

  dimension: sub_matter_min_cd {
    type: string
    sql: ${TABLE}."SUB_MATTER_MIN_CD" ;;
  }

  dimension: sub_matter_min_de {
    type: string
    sql: ${TABLE}."SUB_MATTER_MIN_DE" ;;
  }

  dimension: subscription_delay {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_DELAY" ;;
  }

  dimension: subscription_duration {
    type: number
    sql: ${TABLE}."SUBSCRIPTION_DURATION" ;;
  }

  dimension: subscription_flg {
    type: number
    sql: ${TABLE}."SUBSCRIPTION_FLG" ;;
  }

  dimension: supplement_ptr {
    type: number
    sql: ${TABLE}."SUPPLEMENT_PTR" ;;
  }

  dimension: tech_prod_cd {
    type: string
    sql: ${TABLE}."TECH_PROD_CD" ;;
  }

  dimension: tech_prod_cd_de {
    type: string
    sql: ${TABLE}."TECH_PROD_CD_DE" ;;
  }

  dimension: third_party_dist_cd {
    type: string
    sql: ${TABLE}."THIRD_PARTY_DIST_CD" ;;
  }

  dimension: third_party_dist_de {
    type: string
    sql: ${TABLE}."THIRD_PARTY_DIST_DE" ;;
  }

  dimension: third_party_publisher_cd {
    type: string
    sql: ${TABLE}."THIRD_PARTY_PUBLISHER_CD" ;;
  }

  dimension: third_party_publisher_de {
    type: string
    sql: ${TABLE}."THIRD_PARTY_PUBLISHER_DE" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension: title_code_cd {
    type: string
    sql: ${TABLE}."TITLE_CODE_CD" ;;
  }

  dimension: title_code_de {
    type: string
    sql: ${TABLE}."TITLE_CODE_DE" ;;
  }

  dimension: title_life_months {
    type: number
    sql: ${TABLE}."TITLE_LIFE_MONTHS" ;;
  }

  dimension: title_owner_cd {
    type: string
    sql: ${TABLE}."TITLE_OWNER_CD" ;;
  }

  dimension: title_owner_de {
    type: string
    sql: ${TABLE}."TITLE_OWNER_DE" ;;
  }

  dimension: unit_cost {
    type: number
    sql: ${TABLE}."UNIT_COST" ;;
  }

  dimension: unit_of_measure_cd {
    type: string
    sql: ${TABLE}."UNIT_OF_MEASURE_CD" ;;
  }

  dimension: unit_of_measure_de {
    type: string
    sql: ${TABLE}."UNIT_OF_MEASURE_DE" ;;
  }

  dimension: units_per_carton {
    type: number
    sql: ${TABLE}."UNITS_PER_CARTON" ;;
  }

  dimension: value_alloc_price {
    type: number
    sql: ${TABLE}."VALUE_ALLOC_PRICE" ;;
  }

  dimension: volume_cd {
    type: string
    sql: ${TABLE}."VOLUME_CD" ;;
  }

  dimension: volume_de {
    type: string
    sql: ${TABLE}."VOLUME_DE" ;;
  }

  dimension: weight {
    type: number
    sql: ${TABLE}."WEIGHT" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
