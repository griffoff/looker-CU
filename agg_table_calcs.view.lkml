explore: agg_table_calcs {}


view: agg_table_calcs {
  derived_table: {
    sql: select * from strategy.fall_review_fy20.agg_table_calcs
      ;;
  }

  measure: savings_incl_partners_sum {
    type: sum
    sql: ${TABLE}."SAVINGS_INCL_PARTNERS" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: action_type {
    type: string
    sql: ${TABLE}."ACTION_TYPE" ;;
  }

  dimension: merged_guid {
    type: string
    sql: ${TABLE}."MERGED_GUID" ;;
  }

  dimension: redemp_season {
    type: string
    sql: ${TABLE}."REDEMP_SEASON" ;;
  }

  dimension: redemp_fiscal_year {
    type: number
    sql: ${TABLE}."REDEMP_FISCAL_YEAR" ;;
  }

  dimension: redemp_season_fiscal_year {
    type: string
    sql: ${TABLE}."REDEMP_SEASON_FISCAL_YEAR" ;;
  }

  dimension: action_season {
    type: string
    sql: ${TABLE}."ACTION_SEASON" ;;
  }

  dimension: action_fiscal_year {
    type: number
    sql: ${TABLE}."ACTION_FISCAL_YEAR" ;;
  }

  dimension: action_season_fiscal_year {
    type: string
    sql: ${TABLE}."ACTION_SEASON_FISCAL_YEAR" ;;
  }

  dimension: redemp_key {
    type: string
    sql: ${TABLE}."REDEMP_KEY" ;;
  }

  dimension: actv_key {
    type: string
    sql: ${TABLE}."ACTV_KEY" ;;
  }

  dimension: ebook_key {
    type: string
    sql: ${TABLE}."EBOOK_KEY" ;;
  }

  dimension: matched_redemp_flg {
    type: number
    sql: ${TABLE}."MATCHED_REDEMP_FLG" ;;
  }

  dimension: cu_flg {
    type: string
    sql: ${TABLE}."CU_FLG" ;;
  }

  dimension: hed_flg {
    type: number
    sql: ${TABLE}."HED_FLG" ;;
  }

  dimension: cu_list_spend {
    type: number
    sql: ${TABLE}."CU_LIST_SPEND" ;;
  }

  dimension: cu_student_spend {
    type: number
    sql: ${TABLE}."CU_STUDENT_SPEND" ;;
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

  dimension: matched_ebk_adoption_flg {
    type: number
    sql: ${TABLE}."MATCHED_EBK_ADOPTION_FLG" ;;
  }

  dimension: other_digital_flg {
    type: number
    sql: ${TABLE}."OTHER_DIGITAL_FLG" ;;
  }

  dimension: redemp_entity_no {
    type: number
    sql: ${TABLE}."REDEMP_ENTITY_NO" ;;
  }

  dimension: actv_entity_no {
    type: string
    sql: ${TABLE}."ACTV_ENTITY_NO" ;;
  }

  dimension: upgrade_flg {
    type: number
    sql: ${TABLE}."UPGRADE_FLG" ;;
  }

  dimension: free_upgrade_flg {
    type: number
    sql: ${TABLE}."FREE_UPGRADE_FLG" ;;
  }

  dimension: adoption_key {
    type: string
    sql: ${TABLE}."ADOPTION_KEY" ;;
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

  dimension: cannibalization {
    type: number
    sql: ${TABLE}."CANNIBALIZATION" ;;
  }

  dimension: sales_cannibalization {
    type: number
    sql: ${TABLE}."SALES_CANNIBALIZATION" ;;
  }

  dimension: takeopp_key {
    type: string
    sql: ${TABLE}."TAKEOPP_KEY" ;;
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

  dimension: cancelled_flg {
    type: number
    sql: ${TABLE}."CANCELLED_FLG" ;;
  }

  dimension: hed_savings_rate {
    type: number
    sql: ${TABLE}."HED_SAVINGS_RATE" ;;
  }

  dimension: hed_cannibalization_rate {
    type: number
    sql: ${TABLE}."HED_CANNIBALIZATION_RATE" ;;
  }

  dimension: hed_sales_cannibalization_rate {
    type: number
    sql: ${TABLE}."HED_SALES_CANNIBALIZATION_RATE" ;;
  }

  dimension: hed_savings {
    type: number
    sql: ${TABLE}."HED_SAVINGS" ;;
  }

  dimension: nonhed_savings {
    type: number
    sql: ${TABLE}."NONHED_SAVINGS" ;;
  }

  dimension: hed_cannibalization {
    type: number
    sql: ${TABLE}."HED_CANNIBALIZATION" ;;
  }

  dimension: nonhed_cannibalization {
    type: number
    sql: ${TABLE}."NONHED_CANNIBALIZATION" ;;
  }

  dimension: hed_cu_sales_spend {
    type: number
    sql: ${TABLE}."HED_CU_SALES_SPEND" ;;
  }

  dimension: nonhed_cu_sales_spend {
    type: number
    sql: ${TABLE}."NONHED_CU_SALES_SPEND" ;;
  }

  dimension: hed_sales_cannibalization {
    type: number
    sql: ${TABLE}."HED_SALES_CANNIBALIZATION" ;;
  }

  dimension: nonhed_sales_cannibalization {
    type: number
    sql: ${TABLE}."NONHED_SALES_CANNIBALIZATION" ;;
  }

  dimension: savings_incl_partners {
    type: number
    sql: ${TABLE}."SAVINGS_INCL_PARTNERS" ;;
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

  set: detail {
    fields: [
      action_type,
      merged_guid,
      redemp_season,
      redemp_fiscal_year,
      redemp_season_fiscal_year,
      action_season,
      action_fiscal_year,
      action_season_fiscal_year,
      redemp_key,
      actv_key,
      ebook_key,
      matched_redemp_flg,
      cu_flg,
      hed_flg,
      cu_list_spend,
      cu_student_spend,
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
      chegg_value,
      quizlet_value,
      kaplan_value,
      evernote_value,
      chegg_rental_value,
      partners_value,
      matched_ebk_adoption_flg,
      other_digital_flg,
      redemp_entity_no,
      actv_entity_no,
      upgrade_flg,
      free_upgrade_flg,
      adoption_key,
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
      cannibalization,
      sales_cannibalization,
      takeopp_key,
      takeopp_season,
      takeopp_fiscal_year,
      takeopp_season_fiscal_year,
      cancelled_flg,
      hed_savings_rate,
      hed_cannibalization_rate,
      hed_sales_cannibalization_rate,
      hed_savings,
      nonhed_savings,
      hed_cannibalization,
      nonhed_cannibalization,
      hed_cu_sales_spend,
      nonhed_cu_sales_spend,
      hed_sales_cannibalization,
      nonhed_sales_cannibalization,
      savings_incl_partners,
      takeopp_entity_no,
      institution_nm,
      cui_flg
    ]
  }
}
