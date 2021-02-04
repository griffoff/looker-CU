# explore: z_kpi_savings_cannibalization  {}

# view: z_kpi_savings_cannibalization {
#   derived_table: {
#     sql: SELECT * FROM dev.aa_kpi.savings_cannibalization
#       ;;
#   }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   measure: savings_sum {
#     type: sum
#     sql: ${TABLE}."SAVINGS" ;;
#     drill_fields: [detail*]
#     value_format_name: usd_0
#   }

#   dimension: redemp_key {
#     type: string
#     sql: ${TABLE}."REDEMP_KEY" ;;
#   }

#   dimension: merged_guid {
#     type: string
#     sql: ${TABLE}."MERGED_GUID" ;;
#   }

#   dimension: subscription_duration {
#     type: number
#     sql: ${TABLE}."SUBSCRIPTION_DURATION" ;;
#   }

#   dimension: redemp_season {
#     type: string
#     sql: ${TABLE}."REDEMP_SEASON" ;;
#   }

#   dimension: redemp_fiscal_year {
#     type: number
#     sql: ${TABLE}."REDEMP_FISCAL_YEAR" ;;
#   }

#   dimension: redemp_season_fiscal_year {
#     type: string
#     sql: ${TABLE}."REDEMP_SEASON_FISCAL_YEAR" ;;
#   }

#   dimension: takes {
#     type: number
#     sql: ${TABLE}."TAKES" ;;
#   }

#   dimension: hed_take_opps {
#     type: number
#     sql: ${TABLE}."HED_TAKE_OPPS" ;;
#   }

#   dimension: hed_savings_cann_flg {
#     type: number
#     sql: ${TABLE}."HED_SAVINGS_CANN_FLG" ;;
#   }

#   dimension: savings_cann_flg {
#     type: number
#     sql: ${TABLE}."SAVINGS_CANN_FLG" ;;
#   }

#   dimension: ebk_only_flg {
#     type: number
#     sql: ${TABLE}."EBK_ONLY_FLG" ;;
#   }

#   dimension: sub_dur_spend_base {
#     type: number
#     sql: ${TABLE}."SUB_DUR_SPEND_BASE" ;;
#   }

#   dimension: cu_list_spend {
#     type: number
#     sql: ${TABLE}."CU_LIST_SPEND" ;;
#   }

#   dimension: cu_student_spend {
#     type: number
#     sql: ${TABLE}."CU_STUDENT_SPEND" ;;
#   }

#   dimension: cu_sales_spend {
#     type: number
#     sql: ${TABLE}."CU_SALES_SPEND" ;;
#   }

#   dimension: cu_value_spend {
#     type: number
#     sql: ${TABLE}."CU_VALUE_SPEND" ;;
#   }

#   dimension: unmatched_season {
#     type: string
#     sql: ${TABLE}."UNMATCHED_SEASON" ;;
#   }

#   dimension: unmatched_fiscal_year {
#     type: number
#     sql: ${TABLE}."UNMATCHED_FISCAL_YEAR" ;;
#   }

#   dimension: unmatched_season_fiscal_year {
#     type: string
#     sql: ${TABLE}."UNMATCHED_SEASON_FISCAL_YEAR" ;;
#   }

#   dimension: merged_season {
#     type: string
#     sql: ${TABLE}."MERGED_SEASON" ;;
#   }

#   dimension: merged_fiscal_year {
#     type: number
#     sql: ${TABLE}."MERGED_FISCAL_YEAR" ;;
#   }

#   dimension: merged_season_fiscal_year {
#     type: string
#     sql: ${TABLE}."MERGED_SEASON_FISCAL_YEAR" ;;
#   }

#   dimension: cw_activations {
#     type: number
#     sql: ${TABLE}."CW_ACTIVATIONS" ;;
#   }

#   dimension: cw_list_spend {
#     type: number
#     sql: ${TABLE}."CW_LIST_SPEND" ;;
#   }

#   dimension: cw_student_spend {
#     type: number
#     sql: ${TABLE}."CW_STUDENT_SPEND" ;;
#   }

#   dimension: cw_sales_spend {
#     type: number
#     sql: ${TABLE}."CW_SALES_SPEND" ;;
#   }

#   dimension: cw_value_spend {
#     type: number
#     sql: ${TABLE}."CW_VALUE_SPEND" ;;
#   }

#   dimension: cuflg_cw_activations {
#     type: number
#     sql: ${TABLE}."CUFLG_CW_ACTIVATIONS" ;;
#   }

#   dimension: cuflg_cw_list_spend {
#     type: number
#     sql: ${TABLE}."CUFLG_CW_LIST_SPEND" ;;
#   }

#   dimension: cuflg_cw_student_spend {
#     type: number
#     sql: ${TABLE}."CUFLG_CW_STUDENT_SPEND" ;;
#   }

#   dimension: cuflg_cw_sales_spend {
#     type: number
#     sql: ${TABLE}."CUFLG_CW_SALES_SPEND" ;;
#   }

#   dimension: cuflg_cw_value_spend {
#     type: number
#     sql: ${TABLE}."CUFLG_CW_VALUE_SPEND" ;;
#   }

#   dimension: hed_cw_activations {
#     type: number
#     sql: ${TABLE}."HED_CW_ACTIVATIONS" ;;
#   }

#   dimension: hed_cw_list_spend {
#     type: number
#     sql: ${TABLE}."HED_CW_LIST_SPEND" ;;
#   }

#   dimension: hed_cw_student_spend {
#     type: number
#     sql: ${TABLE}."HED_CW_STUDENT_SPEND" ;;
#   }

#   dimension: hed_cw_sales_spend {
#     type: number
#     sql: ${TABLE}."HED_CW_SALES_SPEND" ;;
#   }

#   dimension: hed_cw_value_spend {
#     type: number
#     sql: ${TABLE}."HED_CW_VALUE_SPEND" ;;
#   }

#   dimension: hed_cuflg_cw_activations {
#     type: number
#     sql: ${TABLE}."HED_CUFLG_CW_ACTIVATIONS" ;;
#   }

#   dimension: hed_cuflg_cw_list_spend {
#     type: number
#     sql: ${TABLE}."HED_CUFLG_CW_LIST_SPEND" ;;
#   }

#   dimension: hed_cuflg_cw_student_spend {
#     type: number
#     sql: ${TABLE}."HED_CUFLG_CW_STUDENT_SPEND" ;;
#   }

#   dimension: hed_cuflg_cw_sales_spend {
#     type: number
#     sql: ${TABLE}."HED_CUFLG_CW_SALES_SPEND" ;;
#   }

#   dimension: hed_cuflg_cw_value_spend {
#     type: number
#     sql: ${TABLE}."HED_CUFLG_CW_VALUE_SPEND" ;;
#   }

#   dimension: hed_ebk_activations {
#     type: number
#     sql: ${TABLE}."HED_EBK_ACTIVATIONS" ;;
#   }

#   dimension: hed_ebk_adop_activations {
#     type: number
#     sql: ${TABLE}."HED_EBK_ADOP_ACTIVATIONS" ;;
#   }

#   dimension: hed_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."HED_EBK_LIST_SPEND" ;;
#   }

#   dimension: hed_ebk_student_spend {
#     type: number
#     sql: ${TABLE}."HED_EBK_STUDENT_SPEND" ;;
#   }

#   dimension: hed_ebk_sales_spend {
#     type: number
#     sql: ${TABLE}."HED_EBK_SALES_SPEND" ;;
#   }

#   dimension: hed_ebk_value_spend {
#     type: number
#     sql: ${TABLE}."HED_EBK_VALUE_SPEND" ;;
#   }

#   dimension: cuflg_cw_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."CUFLG_CW_EBK_LIST_SPEND" ;;
#   }

#   dimension: cuflg_cw_ebk_student_spend {
#     type: number
#     sql: ${TABLE}."CUFLG_CW_EBK_STUDENT_SPEND" ;;
#   }

#   dimension: cuflg_cw_ebk_sales_spend {
#     type: number
#     sql: ${TABLE}."CUFLG_CW_EBK_SALES_SPEND" ;;
#   }

#   dimension: cuflg_cw_ebk_value_spend {
#     type: number
#     sql: ${TABLE}."CUFLG_CW_EBK_VALUE_SPEND" ;;
#   }

#   dimension: savings {
#     type: number
#     sql: ${TABLE}."SAVINGS" ;;
#   }

#   dimension: cannibalization {
#     type: number
#     sql: ${TABLE}."CANNIBALIZATION" ;;
#   }

#   dimension: sm19_cu_student_spend {
#     type: number
#     sql: ${TABLE}."SM19_CU_STUDENT_SPEND" ;;
#   }

#   dimension: fl19_cu_student_spend {
#     type: number
#     sql: ${TABLE}."FL19_CU_STUDENT_SPEND" ;;
#   }

#   dimension: sp19_cu_student_spend {
#     type: number
#     sql: ${TABLE}."SP19_CU_STUDENT_SPEND" ;;
#   }

#   dimension: sm20_cu_student_spend {
#     type: number
#     sql: ${TABLE}."SM20_CU_STUDENT_SPEND" ;;
#   }

#   dimension: fl20_cu_student_spend {
#     type: number
#     sql: ${TABLE}."FL20_CU_STUDENT_SPEND" ;;
#   }

#   dimension: sp20_cu_student_spend {
#     type: number
#     sql: ${TABLE}."SP20_CU_STUDENT_SPEND" ;;
#   }

#   dimension: sm19_cuflg_cw_list_spend {
#     type: number
#     sql: ${TABLE}."SM19_CUFLG_CW_LIST_SPEND" ;;
#   }

#   dimension: fl19_cuflg_cw_list_spend {
#     type: number
#     sql: ${TABLE}."FL19_CUFLG_CW_LIST_SPEND" ;;
#   }

#   dimension: sp19_cuflg_cw_list_spend {
#     type: number
#     sql: ${TABLE}."SP19_CUFLG_CW_LIST_SPEND" ;;
#   }

#   dimension: sm20_cuflg_cw_list_spend {
#     type: number
#     sql: ${TABLE}."SM20_CUFLG_CW_LIST_SPEND" ;;
#   }

#   dimension: fl20_cuflg_cw_list_spend {
#     type: number
#     sql: ${TABLE}."FL20_CUFLG_CW_LIST_SPEND" ;;
#   }

#   dimension: sp20_cuflg_cw_list_spend {
#     type: number
#     sql: ${TABLE}."SP20_CUFLG_CW_LIST_SPEND" ;;
#   }

#   dimension: sm19_hed_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."SM19_HED_EBK_LIST_SPEND" ;;
#   }

#   dimension: fl19_hed_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."FL19_HED_EBK_LIST_SPEND" ;;
#   }

#   dimension: sp19_hed_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."SP19_HED_EBK_LIST_SPEND" ;;
#   }

#   dimension: sm20_hed_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."SM20_HED_EBK_LIST_SPEND" ;;
#   }

#   dimension: fl20_hed_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."FL20_HED_EBK_LIST_SPEND" ;;
#   }

#   dimension: sp20_hed_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."SP20_HED_EBK_LIST_SPEND" ;;
#   }

#   dimension: sm19_cuflg_cw_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."SM19_CUFLG_CW_EBK_LIST_SPEND" ;;
#   }

#   dimension: fl19_cuflg_cw_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."FL19_CUFLG_CW_EBK_LIST_SPEND" ;;
#   }

#   dimension: sp19_cuflg_cw_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."SP19_CUFLG_CW_EBK_LIST_SPEND" ;;
#   }

#   dimension: sm20_cuflg_cw_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."SM20_CUFLG_CW_EBK_LIST_SPEND" ;;
#   }

#   dimension: fl20_cuflg_cw_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."FL20_CUFLG_CW_EBK_LIST_SPEND" ;;
#   }

#   dimension: sp20_cuflg_cw_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."SP20_CUFLG_CW_EBK_LIST_SPEND" ;;
#   }

#   dimension: sm19_savings {
#     type: number
#     sql: ${TABLE}."SM19_SAVINGS" ;;
#   }

#   dimension: fl19_savings {
#     type: number
#     sql: ${TABLE}."FL19_SAVINGS" ;;
#   }

#   dimension: sp19_savings {
#     type: number
#     sql: ${TABLE}."SP19_SAVINGS" ;;
#   }

#   dimension: sm20_savings {
#     type: number
#     sql: ${TABLE}."SM20_SAVINGS" ;;
#   }

#   dimension: fl20_savings {
#     type: number
#     sql: ${TABLE}."FL20_SAVINGS" ;;
#   }

#   dimension: sp20_savings {
#     type: number
#     sql: ${TABLE}."SP20_SAVINGS" ;;
#   }

#   dimension: hed_cuflg_cw_ebk_list_spend {
#     type: number
#     sql: ${TABLE}."HED_CUFLG_CW_EBK_LIST_SPEND" ;;
#   }

#   dimension: hed_cuflg_cw_ebk_student_spend {
#     type: number
#     sql: ${TABLE}."HED_CUFLG_CW_EBK_STUDENT_SPEND" ;;
#   }

#   dimension: hed_cuflg_cw_ebk_sales_spend {
#     type: number
#     sql: ${TABLE}."HED_CUFLG_CW_EBK_SALES_SPEND" ;;
#   }

#   dimension: hed_cuflg_cw_ebk_value_spend {
#     type: number
#     sql: ${TABLE}."HED_CUFLG_CW_EBK_VALUE_SPEND" ;;
#   }

#   dimension: hed_savings {
#     type: number
#     sql: ${TABLE}."HED_SAVINGS" ;;
#   }

#   dimension: hed_cannibalization {
#     type: number
#     sql: ${TABLE}."HED_CANNIBALIZATION" ;;
#   }

#   set: detail {
#     fields: [
#       redemp_key,
#       merged_guid,
#       subscription_duration,
#       redemp_season,
#       redemp_fiscal_year,
#       redemp_season_fiscal_year,
#       takes,
#       hed_take_opps,
#       hed_savings_cann_flg,
#       savings_cann_flg,
#       ebk_only_flg,
#       sub_dur_spend_base,
#       cu_list_spend,
#       cu_student_spend,
#       cu_sales_spend,
#       cu_value_spend,
#       unmatched_season,
#       unmatched_fiscal_year,
#       unmatched_season_fiscal_year,
#       merged_season,
#       merged_fiscal_year,
#       merged_season_fiscal_year,
#       cw_activations,
#       cw_list_spend,
#       cw_student_spend,
#       cw_sales_spend,
#       cw_value_spend,
#       cuflg_cw_activations,
#       cuflg_cw_list_spend,
#       cuflg_cw_student_spend,
#       cuflg_cw_sales_spend,
#       cuflg_cw_value_spend,
#       hed_cw_activations,
#       hed_cw_list_spend,
#       hed_cw_student_spend,
#       hed_cw_sales_spend,
#       hed_cw_value_spend,
#       hed_cuflg_cw_activations,
#       hed_cuflg_cw_list_spend,
#       hed_cuflg_cw_student_spend,
#       hed_cuflg_cw_sales_spend,
#       hed_cuflg_cw_value_spend,
#       hed_ebk_activations,
#       hed_ebk_adop_activations,
#       hed_ebk_list_spend,
#       hed_ebk_student_spend,
#       hed_ebk_sales_spend,
#       hed_ebk_value_spend,
#       cuflg_cw_ebk_list_spend,
#       cuflg_cw_ebk_student_spend,
#       cuflg_cw_ebk_sales_spend,
#       cuflg_cw_ebk_value_spend,
#       savings,
#       cannibalization,
#       sm19_cu_student_spend,
#       fl19_cu_student_spend,
#       sp19_cu_student_spend,
#       sm20_cu_student_spend,
#       fl20_cu_student_spend,
#       sp20_cu_student_spend,
#       sm19_cuflg_cw_list_spend,
#       fl19_cuflg_cw_list_spend,
#       sp19_cuflg_cw_list_spend,
#       sm20_cuflg_cw_list_spend,
#       fl20_cuflg_cw_list_spend,
#       sp20_cuflg_cw_list_spend,
#       sm19_hed_ebk_list_spend,
#       fl19_hed_ebk_list_spend,
#       sp19_hed_ebk_list_spend,
#       sm20_hed_ebk_list_spend,
#       fl20_hed_ebk_list_spend,
#       sp20_hed_ebk_list_spend,
#       sm19_cuflg_cw_ebk_list_spend,
#       fl19_cuflg_cw_ebk_list_spend,
#       sp19_cuflg_cw_ebk_list_spend,
#       sm20_cuflg_cw_ebk_list_spend,
#       fl20_cuflg_cw_ebk_list_spend,
#       sp20_cuflg_cw_ebk_list_spend,
#       sm19_savings,
#       fl19_savings,
#       sp19_savings,
#       sm20_savings,
#       fl20_savings,
#       sp20_savings,
#       hed_cuflg_cw_ebk_list_spend,
#       hed_cuflg_cw_ebk_student_spend,
#       hed_cuflg_cw_ebk_sales_spend,
#       hed_cuflg_cw_ebk_value_spend,
#       hed_savings,
#       hed_cannibalization
#     ]
#   }
# }
