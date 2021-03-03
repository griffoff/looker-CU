view: savings_cann_takes {
  derived_table: {
    sql: SELECT * FROM strategy.fall_review_fy20.savings_cann_takes
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: takeopp_key {
    type: string
    sql: ${TABLE}."TAKEOPP_KEY" ;;
  }

  dimension: redemp_key {
    type: string
    sql: ${TABLE}."REDEMP_KEY" ;;
  }

  dimension: merged_guid {
    type: string
    sql: ${TABLE}."MERGED_GUID" ;;
  }

  dimension: takeopp_season {
    type: string
    sql: ${TABLE}."TAKEOPP_SEASON" ;;
  }

  dimension: takeopp_fiscal_year {
    type: number
    sql: ${TABLE}."TAKEOPP_FISCAL_YEAR" ;;
  }

  dimension: takeopp_season_fiscal_year {
    type: string
    sql: ${TABLE}."TAKEOPP_SEASON_FISCAL_YEAR" ;;
  }

  dimension: takeopp_entity_no {
    type: string
    sql: ${TABLE}."TAKEOPP_ENTITY_NO" ;;
  }

  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
  }

  dimension: cui_flg {
    type: number
    sql: ${TABLE}."CUI_FLG" ;;
  }

  dimension: always_cui_flg {
    type: number
    sql: ${TABLE}."ALWAYS_CUI_FLG" ;;
  }

  dimension: sometimes_cui_flg {
    type: number
    sql: ${TABLE}."SOMETIMES_CUI_FLG" ;;
  }

  dimension: fy_19_star_rating {
    type: number
    sql: ${TABLE}."FY_19_STAR_RATING" ;;
  }

  dimension: fy_20_star_rating {
    type: number
    sql: ${TABLE}."FY_20_STAR_RATING" ;;
  }

  dimension: institution_type {
    type: string
    sql: ${TABLE}."INSTITUTION_TYPE" ;;
  }

  dimension: state_cd {
    type: string
    sql: ${TABLE}."STATE_CD" ;;
  }

  dimension: state_de {
    type: string
    sql: ${TABLE}."STATE_DE" ;;
  }

  dimension: subscription_duration {
    type: number
    sql: ${TABLE}."SUBSCRIPTION_DURATION" ;;
  }

  dimension: bill_to_nm {
    type: string
    sql: ${TABLE}."BILL_TO_NM" ;;
  }

  dimension: cu_list_spend {
    type: number
    sql: ${TABLE}."CU_LIST_SPEND" ;;
  }

  dimension: cu_student_spend {
    type: number
    sql: ${TABLE}."CU_STUDENT_SPEND" ;;
  }

  dimension: nonhed_cu_sales_spend {
    type: number
    sql: ${TABLE}."NONHED_CU_SALES_SPEND" ;;
  }

  dimension: hed_cu_sales_spend {
    type: number
    sql: ${TABLE}."HED_CU_SALES_SPEND" ;;
  }

  dimension: upgrade_flg {
    type: number
    sql: ${TABLE}."UPGRADE_FLG" ;;
  }

  dimension: free_upgrade_flg {
    type: number
    sql: ${TABLE}."FREE_UPGRADE_FLG" ;;
  }

  dimension: cu_sales_spend {
    type: number
    sql: ${TABLE}."CU_SALES_SPEND" ;;
  }

  dimension: cu_value_spend {
    type: number
    sql: ${TABLE}."CU_VALUE_SPEND" ;;
  }

  dimension: cw_list_spend {
    type: number
    sql: ${TABLE}."CW_LIST_SPEND" ;;
  }

  dimension: cw_student_spend {
    type: number
    sql: ${TABLE}."CW_STUDENT_SPEND" ;;
  }

  dimension: cw_sales_spend {
    type: number
    sql: ${TABLE}."CW_SALES_SPEND" ;;
  }

  dimension: cw_value_spend {
    type: number
    sql: ${TABLE}."CW_VALUE_SPEND" ;;
  }

  dimension: cuflg_ebk_list_spend {
    type: number
    sql: ${TABLE}."CUFLG_EBK_LIST_SPEND" ;;
  }

  dimension: cuflg_ebk_student_spend {
    type: number
    sql: ${TABLE}."CUFLG_EBK_STUDENT_SPEND" ;;
  }

  dimension: cuflg_ebk_sales_spend {
    type: number
    sql: ${TABLE}."CUFLG_EBK_SALES_SPEND" ;;
  }

  dimension: cuflg_ebk_value_spend {
    type: number
    sql: ${TABLE}."CUFLG_EBK_VALUE_SPEND" ;;
  }

  dimension: cw_activations {
    type: number
    sql: ${TABLE}."CW_ACTIVATIONS" ;;
  }

  dimension: hed_cw_activations {
    type: number
    sql: ${TABLE}."HED_CW_ACTIVATIONS" ;;
  }

  dimension: nonhed_cw_activations {
    type: number
    sql: ${TABLE}."NONHED_CW_ACTIVATIONS" ;;
  }

  dimension: cuflg_cw_activations {
    type: number
    sql: ${TABLE}."CUFLG_CW_ACTIVATIONS" ;;
  }

  dimension: hed_cuflg_cw_activations {
    type: number
    sql: ${TABLE}."HED_CUFLG_CW_ACTIVATIONS" ;;
  }

  dimension: nonhed_cuflg_cw_activations {
    type: number
    sql: ${TABLE}."NONHED_CUFLG_CW_ACTIVATIONS" ;;
  }

  dimension: ebk_activations {
    type: number
    sql: ${TABLE}."EBK_ACTIVATIONS" ;;
  }

  dimension: ebk_adop_activations {
    type: number
    sql: ${TABLE}."EBK_ADOP_ACTIVATIONS" ;;
  }

  dimension: hed_ebk_adop_activations {
    type: number
    sql: ${TABLE}."HED_EBK_ADOP_ACTIVATIONS" ;;
  }

  dimension: nonhed_ebk_adop_activations {
    type: number
    sql: ${TABLE}."NONHED_EBK_ADOP_ACTIVATIONS" ;;
  }

  dimension: hed_cw_list_spend {
    type: number
    sql: ${TABLE}."HED_CW_LIST_SPEND" ;;
  }

  dimension: hed_cw_student_spend {
    type: number
    sql: ${TABLE}."HED_CW_STUDENT_SPEND" ;;
  }

  dimension: hed_cw_sales_spend {
    type: number
    sql: ${TABLE}."HED_CW_SALES_SPEND" ;;
  }

  dimension: hed_cw_value_spend {
    type: number
    sql: ${TABLE}."HED_CW_VALUE_SPEND" ;;
  }

  dimension: cuflg_cw_list_spend {
    type: number
    sql: ${TABLE}."CUFLG_CW_LIST_SPEND" ;;
  }

  dimension: cuflg_cw_student_spend {
    type: number
    sql: ${TABLE}."CUFLG_CW_STUDENT_SPEND" ;;
  }

  dimension: cuflg_cw_sales_spend {
    type: number
    sql: ${TABLE}."CUFLG_CW_SALES_SPEND" ;;
  }

  dimension: cuflg_cw_value_spend {
    type: number
    sql: ${TABLE}."CUFLG_CW_VALUE_SPEND" ;;
  }

  dimension: hed_cuflg_cw_list_spend {
    type: number
    sql: ${TABLE}."HED_CUFLG_CW_LIST_SPEND" ;;
  }

  dimension: hed_cuflg_cw_student_spend {
    type: number
    sql: ${TABLE}."HED_CUFLG_CW_STUDENT_SPEND" ;;
  }

  dimension: hed_cuflg_cw_sales_spend {
    type: number
    sql: ${TABLE}."HED_CUFLG_CW_SALES_SPEND" ;;
  }

  dimension: hed_cuflg_cw_value_spend {
    type: number
    sql: ${TABLE}."HED_CUFLG_CW_VALUE_SPEND" ;;
  }

  dimension: hed_cuflg_ebk_list_spend {
    type: number
    sql: ${TABLE}."HED_CUFLG_EBK_LIST_SPEND" ;;
  }

  dimension: hed_cuflg_ebk_student_spend {
    type: number
    sql: ${TABLE}."HED_CUFLG_EBK_STUDENT_SPEND" ;;
  }

  dimension: hed_cuflg_ebk_sales_spend {
    type: number
    sql: ${TABLE}."HED_CUFLG_EBK_SALES_SPEND" ;;
  }

  dimension: hed_cuflg_ebk_value_spend {
    type: number
    sql: ${TABLE}."HED_CUFLG_EBK_VALUE_SPEND" ;;
  }

  dimension: cwebk_list_spend {
    type: number
    sql: ${TABLE}."CWEBK_LIST_SPEND" ;;
  }

  dimension: cwebk_student_spend {
    type: number
    sql: ${TABLE}."CWEBK_STUDENT_SPEND" ;;
  }

  dimension: cwebk_sales_spend {
    type: number
    sql: ${TABLE}."CWEBK_SALES_SPEND" ;;
  }

  dimension: cwebk_value_spend {
    type: number
    sql: ${TABLE}."CWEBK_VALUE_SPEND" ;;
  }

  dimension: hed_cwebk_list_spend {
    type: number
    sql: ${TABLE}."HED_CWEBK_LIST_SPEND" ;;
  }

  dimension: hed_cwebk_student_spend {
    type: number
    sql: ${TABLE}."HED_CWEBK_STUDENT_SPEND" ;;
  }

  dimension: hed_cwebk_sales_spend {
    type: number
    sql: ${TABLE}."HED_CWEBK_SALES_SPEND" ;;
  }

  dimension: hed_cwebk_value_spend {
    type: number
    sql: ${TABLE}."HED_CWEBK_VALUE_SPEND" ;;
  }

  dimension: cuflg_cwebk_list_spend {
    type: number
    sql: ${TABLE}."CUFLG_CWEBK_LIST_SPEND" ;;
  }

  dimension: cuflg_cwebk_student_spend {
    type: number
    sql: ${TABLE}."CUFLG_CWEBK_STUDENT_SPEND" ;;
  }

  dimension: cuflg_cwebk_sales_spend {
    type: number
    sql: ${TABLE}."CUFLG_CWEBK_SALES_SPEND" ;;
  }

  dimension: cuflg_cwebk_value_spend {
    type: number
    sql: ${TABLE}."CUFLG_CWEBK_VALUE_SPEND" ;;
  }

  dimension: hed_cuflg_cwebk_list_spend {
    type: number
    sql: ${TABLE}."HED_CUFLG_CWEBK_LIST_SPEND" ;;
  }

  dimension: hed_cuflg_cwebk_student_spend {
    type: number
    sql: ${TABLE}."HED_CUFLG_CWEBK_STUDENT_SPEND" ;;
  }

  dimension: hed_cuflg_cwebk_sales_spend {
    type: number
    sql: ${TABLE}."HED_CUFLG_CWEBK_SALES_SPEND" ;;
  }

  dimension: hed_cuflg_cwebk_value_spend {
    type: number
    sql: ${TABLE}."HED_CUFLG_CWEBK_VALUE_SPEND" ;;
  }

  dimension: savings {
    type: number
    sql: ${TABLE}."SAVINGS" ;;
  }

  dimension: hed_savings {
    type: number
    sql: ${TABLE}."HED_SAVINGS" ;;
  }

  dimension: nonhed_savings {
    type: number
    sql: ${TABLE}."NONHED_SAVINGS" ;;
  }

  dimension: cannibalization {
    type: number
    sql: ${TABLE}."CANNIBALIZATION" ;;
  }

  dimension: hed_cannibalization {
    type: number
    sql: ${TABLE}."HED_CANNIBALIZATION" ;;
  }

  dimension: nonhed_cannibalization {
    type: number
    sql: ${TABLE}."NONHED_CANNIBALIZATION" ;;
  }

  dimension: sales_cannibalization {
    type: number
    sql: ${TABLE}."SALES_CANNIBALIZATION" ;;
  }

  dimension: hed_sales_cannibalization {
    type: number
    sql: ${TABLE}."HED_SALES_CANNIBALIZATION" ;;
  }

  dimension: nonhed_sales_cannibalization {
    type: number
    sql: ${TABLE}."NONHED_SALES_CANNIBALIZATION" ;;
  }

  dimension: chegg_value {
    type: number
    sql: ${TABLE}."CHEGG_VALUE" ;;
  }

  dimension: quizlet_value {
    type: number
    sql: ${TABLE}."QUIZLET_VALUE" ;;
  }

  dimension: kaplan_value {
    type: number
    sql: ${TABLE}."KAPLAN_VALUE" ;;
  }

  dimension: evernote_value {
    type: number
    sql: ${TABLE}."EVERNOTE_VALUE" ;;
  }

  dimension: chegg_rental_value {
    type: number
    sql: ${TABLE}."CHEGG_RENTAL_VALUE" ;;
  }

  dimension: partners_value {
    type: number
    sql: ${TABLE}."PARTNERS_VALUE" ;;
  }

  dimension: savings_incl_partners {
    type: number
    sql: ${TABLE}."SAVINGS_INCL_PARTNERS" ;;
  }

  dimension: unmatched_cu_flg {
    type: number
    sql: ${TABLE}."UNMATCHED_CU_FLG" ;;
  }

  dimension: any_cu_flg {
    type: number
    sql: ${TABLE}."ANY_CU_FLG" ;;
  }

  dimension: bill_to_nm_grp {
    type: string
    sql: ${TABLE}."BILL_TO_NM_GRP" ;;
  }

  dimension: takes {
    type: number
    sql: ${TABLE}."TAKES" ;;
  }

  dimension: hed_take_opps {
    type: number
    sql: ${TABLE}."HED_TAKE_OPPS" ;;
  }

  dimension: cannibalization_flg {
    type: number
    sql: ${TABLE}."CANNIBALIZATION_FLG" ;;
  }

  dimension: hed_cannibalization_flg {
    type: number
    sql: ${TABLE}."HED_CANNIBALIZATION_FLG" ;;
  }

  dimension: nonhed_cannibalization_flg {
    type: number
    sql: ${TABLE}."NONHED_CANNIBALIZATION_FLG" ;;
  }

  dimension: savings_cann_flg {
    type: number
    sql: ${TABLE}."SAVINGS_CANN_FLG" ;;
  }

  dimension: ebk_only_flg {
    type: number
    sql: ${TABLE}."EBK_ONLY_FLG" ;;
  }

  dimension: ebk_adop_only_flg {
    type: number
    sql: ${TABLE}."EBK_ADOP_ONLY_FLG" ;;
  }

  dimension: pos_savings_flg {
    type: number
    sql: ${TABLE}."POS_SAVINGS_FLG" ;;
  }

  dimension: pos_savings_incl_partners_flg {
    type: number
    sql: ${TABLE}."POS_SAVINGS_INCL_PARTNERS_FLG" ;;
  }

  dimension: cw_student_spend_bucket {
    type: string
    sql: ${TABLE}."CW_STUDENT_SPEND_BUCKET" ;;
  }

  dimension: cwebk_student_spend_bucket {
    type: string
    sql: ${TABLE}."CWEBK_STUDENT_SPEND_BUCKET" ;;
  }

  set: detail {
    fields: [
      takeopp_key,
      redemp_key,
      merged_guid,
      takeopp_season,
      takeopp_fiscal_year,
      takeopp_season_fiscal_year,
      takeopp_entity_no,
      institution_nm,
      cui_flg,
      always_cui_flg,
      sometimes_cui_flg,
      fy_19_star_rating,
      fy_20_star_rating,
      institution_type,
      state_cd,
      state_de,
      subscription_duration,
      bill_to_nm,
      cu_list_spend,
      cu_student_spend,
      nonhed_cu_sales_spend,
      hed_cu_sales_spend,
      upgrade_flg,
      free_upgrade_flg,
      cu_sales_spend,
      cu_value_spend,
      cw_list_spend,
      cw_student_spend,
      cw_sales_spend,
      cw_value_spend,
      cuflg_ebk_list_spend,
      cuflg_ebk_student_spend,
      cuflg_ebk_sales_spend,
      cuflg_ebk_value_spend,
      cw_activations,
      hed_cw_activations,
      nonhed_cw_activations,
      cuflg_cw_activations,
      hed_cuflg_cw_activations,
      nonhed_cuflg_cw_activations,
      ebk_activations,
      ebk_adop_activations,
      hed_ebk_adop_activations,
      nonhed_ebk_adop_activations,
      hed_cw_list_spend,
      hed_cw_student_spend,
      hed_cw_sales_spend,
      hed_cw_value_spend,
      cuflg_cw_list_spend,
      cuflg_cw_student_spend,
      cuflg_cw_sales_spend,
      cuflg_cw_value_spend,
      hed_cuflg_cw_list_spend,
      hed_cuflg_cw_student_spend,
      hed_cuflg_cw_sales_spend,
      hed_cuflg_cw_value_spend,
      hed_cuflg_ebk_list_spend,
      hed_cuflg_ebk_student_spend,
      hed_cuflg_ebk_sales_spend,
      hed_cuflg_ebk_value_spend,
      cwebk_list_spend,
      cwebk_student_spend,
      cwebk_sales_spend,
      cwebk_value_spend,
      hed_cwebk_list_spend,
      hed_cwebk_student_spend,
      hed_cwebk_sales_spend,
      hed_cwebk_value_spend,
      cuflg_cwebk_list_spend,
      cuflg_cwebk_student_spend,
      cuflg_cwebk_sales_spend,
      cuflg_cwebk_value_spend,
      hed_cuflg_cwebk_list_spend,
      hed_cuflg_cwebk_student_spend,
      hed_cuflg_cwebk_sales_spend,
      hed_cuflg_cwebk_value_spend,
      savings,
      hed_savings,
      nonhed_savings,
      cannibalization,
      hed_cannibalization,
      nonhed_cannibalization,
      sales_cannibalization,
      hed_sales_cannibalization,
      nonhed_sales_cannibalization,
      chegg_value,
      quizlet_value,
      kaplan_value,
      evernote_value,
      chegg_rental_value,
      partners_value,
      savings_incl_partners,
      unmatched_cu_flg,
      any_cu_flg,
      bill_to_nm_grp,
      takes,
      hed_take_opps,
      cannibalization_flg,
      hed_cannibalization_flg,
      nonhed_cannibalization_flg,
      savings_cann_flg,
      ebk_only_flg,
      ebk_adop_only_flg,
      pos_savings_flg,
      pos_savings_incl_partners_flg,
      cw_student_spend_bucket,
      cwebk_student_spend_bucket
    ]
  }
}
