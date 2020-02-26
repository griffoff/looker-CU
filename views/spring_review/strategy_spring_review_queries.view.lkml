explore: strategy_spring_review_queries {}

view: strategy_spring_review_queries {
  derived_table: {
    sql: SELECT * FROM dev.strategy_spring_review_queries.sr_actv_and_cu_merge_consol
      ;;
  }



  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: merged_guid {
    type: string
    sql: ${TABLE}."MERGED_GUID" ;;
  }

  dimension: upgrade_source {
    type: string
    sql: ${TABLE}."UPGRADE_SOURCE" ;;
  }

  dimension: cu_redemption_entity_no {
    type: number
    sql: ${TABLE}."CU_REDEMPTION_ENTITY_NO" ;;
  }

  dimension: fl_19_cu_user_flg {
    type: number
    sql: ${TABLE}."FL_19_CU_USER_FLG" ;;
  }

  dimension: fl_19_cu_upgrade_flg {
    type: number
    sql: ${TABLE}."FL_19_CU_UPGRADE_FLG" ;;
  }

  dimension: fl_19_stud_spd_list {
    type: number
    sql: ${TABLE}."FL_19_STUD_SPD_LIST" ;;
  }

  dimension: fl_19_stud_spd_list_bycu {
    type: number
    sql: ${TABLE}."FL_19_STUD_SPD_LIST_BYCU" ;;
  }

  dimension: fl_19_stud_ebk_spd_list_bycu {
    type: number
    sql: ${TABLE}."FL_19_STUD_EBK_SPD_LIST_BYCU" ;;
  }

  dimension: fl_19_stud_spd_list_w_ebk_bycu {
    type: number
    sql: ${TABLE}."FL_19_STUD_SPD_LIST_W_EBK_BYCU" ;;
  }

  dimension: fl_19_stud_ebk_spd_bycu {
    type: number
    sql: ${TABLE}."FL_19_STUD_EBK_SPD_BYCU" ;;
  }

  dimension: fl_19_ebk_netsls_bycu {
    type: number
    sql: ${TABLE}."FL_19_EBK_NETSLS_BYCU" ;;
  }

  dimension: fl_19_stud_spd {
    type: number
    sql: ${TABLE}."FL_19_STUD_SPD" ;;
  }

  dimension: fl_19_stud_spd_w_ebk_bycu {
    type: number
    sql: ${TABLE}."FL_19_STUD_SPD_W_EBK_BYCU" ;;
  }

  dimension: fl_19_cl_net_sales_value {
    type: number
    sql: ${TABLE}."FL_19_CL_NET_SALES_VALUE" ;;
  }

  dimension: fl_19_cl_net_sales_bycu {
    type: number
    sql: ${TABLE}."FL_19_CL_NET_SALES_BYCU" ;;
  }

  dimension: fl_19_cl_net_sales_w_ebk_bycu {
    type: number
    sql: ${TABLE}."FL_19_CL_NET_SALES_W_EBK_BYCU" ;;
  }

  dimension: fl_19_activation_units {
    type: number
    sql: ${TABLE}."FL_19_ACTIVATION_UNITS" ;;
  }

  dimension: fl_19_activation_units_bycu {
    type: number
    sql: ${TABLE}."FL_19_ACTIVATION_UNITS_BYCU" ;;
  }

  dimension: fl_19_actv_units_ebk_bycu {
    type: number
    sql: ${TABLE}."FL_19_ACTV_UNITS_EBK_BYCU" ;;
  }

  dimension: fl_19_adop_units_ebk_bycu {
    type: number
    sql: ${TABLE}."FL_19_ADOP_UNITS_EBK_BYCU" ;;
  }

  dimension: fl_19_isbn_sub_dur {
    type: number
    sql: ${TABLE}."FL_19_ISBN_SUB_DUR" ;;
  }

  dimension: fl_19_sumofdays_paid {
    type: number
    sql: ${TABLE}."FL_19_SUMOFDAYS_PAID" ;;
  }

  dimension: fl_19_cu_spend {
    type: number
    sql: ${TABLE}."FL_19_CU_SPEND" ;;
  }

  dimension: fl_19_cu_cl_net_sales {
    type: number
    sql: ${TABLE}."FL_19_CU_CL_NET_SALES" ;;
  }

  dimension: fl_19_bkstr_redemp_flg {
    type: number
    sql: ${TABLE}."FL_19_BKSTR_REDEMP_FLG" ;;
  }

  dimension: fl_19_ecom_redemp_flg {
    type: number
    sql: ${TABLE}."FL_19_ECOM_REDEMP_FLG" ;;
  }

  dimension: fl_19_pac_flg {
    type: number
    sql: ${TABLE}."FL_19_PAC_FLG" ;;
  }

  dimension: fl_19_sum_of_matched_redemp {
    type: number
    sql: ${TABLE}."FL_19_SUM_OF_MATCHED_REDEMP" ;;
  }

  dimension: sp_19_cu_user_flg {
    type: number
    sql: ${TABLE}."SP_19_CU_USER_FLG" ;;
  }

  dimension: sp_19_cu_upgrade_flg {
    type: number
    sql: ${TABLE}."SP_19_CU_UPGRADE_FLG" ;;
  }

  dimension: sp_19_stud_spd_list {
    type: number
    sql: ${TABLE}."SP_19_STUD_SPD_LIST" ;;
  }

  dimension: sp_19_stud_spd_list_bycu {
    type: number
    sql: ${TABLE}."SP_19_STUD_SPD_LIST_BYCU" ;;
  }

  dimension: sp_19_stud_ebk_spd_list_bycu {
    type: number
    sql: ${TABLE}."SP_19_STUD_EBK_SPD_LIST_BYCU" ;;
  }

  dimension: sp_19_stud_spd_list_w_ebk_bycu {
    type: number
    sql: ${TABLE}."SP_19_STUD_SPD_LIST_W_EBK_BYCU" ;;
  }

  dimension: sp_19_stud_ebk_spd_bycu {
    type: number
    sql: ${TABLE}."SP_19_STUD_EBK_SPD_BYCU" ;;
  }

  dimension: sp_19_ebk_netsls_bycu {
    type: number
    sql: ${TABLE}."SP_19_EBK_NETSLS_BYCU" ;;
  }

  dimension: sp_19_cl_net_sales_w_ebk_bycu {
    type: number
    sql: ${TABLE}."SP_19_CL_NET_SALES_W_EBK_BYCU" ;;
  }

  dimension: sp_19_stud_spd {
    type: number
    sql: ${TABLE}."SP_19_STUD_SPD" ;;
  }

  dimension: sp_19_stud_spd_w_ebk_bycu {
    type: number
    sql: ${TABLE}."SP_19_STUD_SPD_W_EBK_BYCU" ;;
  }

  dimension: sp_19_cl_net_sales_value {
    type: number
    sql: ${TABLE}."SP_19_CL_NET_SALES_VALUE" ;;
  }

  dimension: sp_19_cl_net_sales_bycu {
    type: number
    sql: ${TABLE}."SP_19_CL_NET_SALES_BYCU" ;;
  }

  dimension: sp_19_activation_units {
    type: number
    sql: ${TABLE}."SP_19_ACTIVATION_UNITS" ;;
  }

  dimension: sp_19_activation_units_bycu {
    type: number
    sql: ${TABLE}."SP_19_ACTIVATION_UNITS_BYCU" ;;
  }

  dimension: sp_19_actv_units_ebk_bycu {
    type: number
    sql: ${TABLE}."SP_19_ACTV_UNITS_EBK_BYCU" ;;
  }

  dimension: sp_19_adop_units_ebk_bycu {
    type: number
    sql: ${TABLE}."SP_19_ADOP_UNITS_EBK_BYCU" ;;
  }

  dimension: sp_19_isbn_sub_dur {
    type: number
    sql: ${TABLE}."SP_19_ISBN_SUB_DUR" ;;
  }

  dimension: sp_19_sumofdays_paid {
    type: number
    sql: ${TABLE}."SP_19_SUMOFDAYS_PAID" ;;
  }

  dimension: sp_19_cu_spend {
    type: number
    sql: ${TABLE}."SP_19_CU_SPEND" ;;
  }

  dimension: sp_19_cu_cl_net_sales {
    type: number
    sql: ${TABLE}."SP_19_CU_CL_NET_SALES" ;;
  }

  dimension: sp_19_bkstr_redemp_flg {
    type: number
    sql: ${TABLE}."SP_19_BKSTR_REDEMP_FLG" ;;
  }

  dimension: sp_19_ecom_redemp_flg {
    type: number
    sql: ${TABLE}."SP_19_ECOM_REDEMP_FLG" ;;
  }

  dimension: sp_19_pac_flg {
    type: number
    sql: ${TABLE}."SP_19_PAC_FLG" ;;
  }

  dimension: sp_19_sum_of_matched_redemp {
    type: number
    sql: ${TABLE}."SP_19_SUM_OF_MATCHED_REDEMP" ;;
  }

  dimension: max_actv_entity_id_cleansed {
    type: number
    sql: ${TABLE}."MAX_ACTV_ENTITY_ID_CLEANSED" ;;
  }

  dimension: merged_entity_no {
    type: number
    sql: ${TABLE}."MERGED_ENTITY_NO" ;;
  }

  dimension: all_19_cu_user_flg {
    type: number
    sql: ${TABLE}."ALL_19_CU_USER_FLG" ;;
  }

  dimension: cu_subscriber_flg {
    type: number
    sql: ${TABLE}."CU_SUBSCRIBER_FLG" ;;
  }

  dimension: all_19_cu_redemp_flg {
    type: number
    sql: ${TABLE}."ALL_19_CU_REDEMP_FLG" ;;
  }

  dimension: all_19_cu_upgrade_flg {
    type: number
    sql: ${TABLE}."ALL_19_CU_UPGRADE_FLG" ;;
  }

  dimension: all_19_stud_spd_list {
    type: number
    sql: ${TABLE}."ALL_19_STUD_SPD_LIST" ;;
  }

  dimension: all_19_stud_ebk_spd_list_bycu {
    type: number
    sql: ${TABLE}."ALL_19_STUD_EBK_SPD_LIST_BYCU" ;;
  }

  dimension: all_19_stud_spd_list_bycu {
    type: number
    sql: ${TABLE}."ALL_19_STUD_SPD_LIST_BYCU" ;;
  }

  dimension: all_19_stud_spd_list_w_ebk_bycu {
    type: number
    sql: ${TABLE}."ALL_19_STUD_SPD_LIST_W_EBK_BYCU" ;;
  }

  dimension: all_19_stud_ebk_spd_bycu {
    type: number
    sql: ${TABLE}."ALL_19_STUD_EBK_SPD_BYCU" ;;
  }

  dimension: all_19_ebk_netsls_bycu {
    type: number
    sql: ${TABLE}."ALL_19_EBK_NETSLS_BYCU" ;;
  }

  dimension: all_19_stud_spd {
    type: number
    sql: ${TABLE}."ALL_19_STUD_SPD" ;;
  }

  dimension: all_19_cl_net_sales_value {
    type: number
    sql: ${TABLE}."ALL_19_CL_NET_SALES_VALUE" ;;
  }

  dimension: all_19_cl_net_sales_bycu {
    type: number
    sql: ${TABLE}."ALL_19_CL_NET_SALES_BYCU" ;;
  }

  dimension: all_19_cl_net_sales_w_ebk_bycu {
    type: number
    sql: ${TABLE}."ALL_19_CL_NET_SALES_W_EBK_BYCU" ;;
  }

  dimension: all_19_activation_units {
    type: number
    sql: ${TABLE}."ALL_19_ACTIVATION_UNITS" ;;
  }

  dimension: all_19_activation_units_bycu {
    type: number
    sql: ${TABLE}."ALL_19_ACTIVATION_UNITS_BYCU" ;;
  }

  dimension: all_19_actv_units_ebk_bycu {
    type: number
    sql: ${TABLE}."ALL_19_ACTV_UNITS_EBK_BYCU" ;;
  }

  dimension: all_19_adop_units_ebk_bycu {
    type: number
    sql: ${TABLE}."ALL_19_ADOP_UNITS_EBK_BYCU" ;;
  }

  dimension: all_19_cu_spend {
    type: number
    sql: ${TABLE}."ALL_19_CU_SPEND" ;;
  }

  dimension: all_19_cu_cl_net_sales {
    type: number
    sql: ${TABLE}."ALL_19_CU_CL_NET_SALES" ;;
  }

  dimension: all_19_bkstr_redemp_flg {
    type: number
    sql: ${TABLE}."ALL_19_BKSTR_REDEMP_FLG" ;;
  }

  dimension: all_19_ecom_redemp_flg {
    type: number
    sql: ${TABLE}."ALL_19_ECOM_REDEMP_FLG" ;;
  }

  dimension: all_19_pac_flg {
    type: number
    sql: ${TABLE}."ALL_19_PAC_FLG" ;;
  }

  dimension: all_19_sum_of_matched_redemp {
    type: number
    sql: ${TABLE}."ALL_19_SUM_OF_MATCHED_REDEMP" ;;
  }

  dimension: fl_19_master_sub_dur {
    type: number
    sql: ${TABLE}."FL_19_MASTER_SUB_DUR" ;;
  }

  dimension: sp_19_master_sub_dur {
    type: number
    sql: ${TABLE}."SP_19_MASTER_SUB_DUR" ;;
  }

  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
  }

  dimension: mkt_seg_min_de {
    type: string
    sql: ${TABLE}."MKT_SEG_MIN_DE" ;;
  }

  dimension: inst_2_yr_4_yr {
    type: string
    sql: ${TABLE}."INST_2_YR_4_YR" ;;
  }

  dimension: inst_cui_flg {
    type: number
    sql: ${TABLE}."INST_CUI_FLG" ;;
  }

  dimension: inst_star_rating {
    type: string
    sql: ${TABLE}."INST_STAR_RATING" ;;
  }

  dimension: fl_19_big_spend_bucket {
    type: string
    sql: ${TABLE}."FL_19_BIG_SPEND_BUCKET" ;;
  }

  dimension: sp_19_big_spend_bucket {
    type: string
    sql: ${TABLE}."SP_19_BIG_SPEND_BUCKET" ;;
  }

  dimension: fl_19_big_spd_bckt_w_ebk_bycu {
    type: string
    sql: ${TABLE}."FL_19_BIG_SPD_BCKT_W_EBK_BYCU" ;;
  }

  dimension: sp_19_big_spd_bckt_w_ebk_bycu {
    type: string
    sql: ${TABLE}."SP_19_BIG_SPD_BCKT_W_EBK_BYCU" ;;
  }

  dimension: fl_19_sub_dur_cat {
    type: string
    sql: ${TABLE}."FL_19_SUB_DUR_CAT" ;;
  }

  dimension: sp_19_sub_dur_cat {
    type: string
    sql: ${TABLE}."SP_19_SUB_DUR_CAT" ;;
  }

  dimension: fl_19_renewal_flg {
    type: number
    sql: ${TABLE}."FL_19_RENEWAL_FLG" ;;
  }

  dimension: sp_19_renewal_flg {
    type: number
    sql: ${TABLE}."SP_19_RENEWAL_FLG" ;;
  }

  dimension: fl_19_cann_no_ebk {
    type: number
    sql: ${TABLE}."FL_19_CANN_NO_EBK" ;;
  }

  dimension: sp_19_cann_no_ebk {
    type: number
    sql: ${TABLE}."SP_19_CANN_NO_EBK" ;;
  }

  dimension: fl_19_cann {
    type: number
    sql: ${TABLE}."FL_19_CANN" ;;
  }

  dimension: sp_19_cann {
    type: number
    sql: ${TABLE}."SP_19_CANN" ;;
  }

  dimension: fl_19_spend_bucket {
    type: number
    sql: ${TABLE}."FL_19_SPEND_BUCKET" ;;
  }

  dimension: sp_19_spend_bucket {
    type: number
    sql: ${TABLE}."SP_19_SPEND_BUCKET" ;;
  }

  dimension: fl_19_savings {
    type: number
    sql: ${TABLE}."FL_19_SAVINGS" ;;
  }

  dimension: sp_19_savings {
    type: number
    sql: ${TABLE}."SP_19_SAVINGS" ;;
  }

  dimension: fl_19_pos_cu_spend_flg {
    type: number
    sql: ${TABLE}."FL_19_POS_CU_SPEND_FLG" ;;
  }

  dimension: sp_19_pos_cu_spend_flg {
    type: number
    sql: ${TABLE}."SP_19_POS_CU_SPEND_FLG" ;;
  }

  dimension: fl_19_pos_savings_flg {
    type: number
    sql: ${TABLE}."FL_19_POS_SAVINGS_FLG" ;;
  }

  dimension: sp_19_pos_savings_flg {
    type: number
    sql: ${TABLE}."SP_19_POS_SAVINGS_FLG" ;;
  }

  dimension: fl_19_alc_only_flg {
    type: number
    sql: ${TABLE}."FL_19_ALC_ONLY_FLG" ;;
  }

  dimension: sp_19_alc_only_flg {
    type: number
    sql: ${TABLE}."SP_19_ALC_ONLY_FLG" ;;
  }

  dimension: fl_19_nothing_flg {
    type: number
    sql: ${TABLE}."FL_19_NOTHING_FLG" ;;
  }

  dimension: sp_19_nothing_flg {
    type: number
    sql: ${TABLE}."SP_19_NOTHING_FLG" ;;
  }

  dimension: fl_19_omitted_cu_user_flg {
    type: number
    sql: ${TABLE}."FL_19_OMITTED_CU_USER_FLG" ;;
  }

  dimension: sp_19_omitted_cu_user_flg {
    type: number
    sql: ${TABLE}."SP_19_OMITTED_CU_USER_FLG" ;;
  }

  dimension: all_19_cann {
    type: number
    sql: ${TABLE}."ALL_19_CANN" ;;
  }

  dimension: all_19_cann_no_ebk {
    type: number
    sql: ${TABLE}."ALL_19_CANN_NO_EBK" ;;
  }

  dimension: all_19_savings {
    type: number
    sql: ${TABLE}."ALL_19_SAVINGS" ;;
  }

  dimension: fl_19_takes {
    type: number
    sql: ${TABLE}."FL_19_TAKES" ;;
  }

  dimension: fl_19_take_opps {
    type: number
    sql: ${TABLE}."FL_19_TAKE_OPPS" ;;
  }

  dimension: sp_19_takes {
    type: number
    sql: ${TABLE}."SP_19_TAKES" ;;
  }

  dimension: sp_19_take_opps {
    type: number
    sql: ${TABLE}."SP_19_TAKE_OPPS" ;;
  }

  dimension: all_19_takes {
    type: number
    sql: ${TABLE}."ALL_19_TAKES" ;;
  }

  dimension: all_19_take_opps {
    type: number
    sql: ${TABLE}."ALL_19_TAKE_OPPS" ;;
  }

  dimension: fl_19_single_course_disc {
    type: string
    sql: ${TABLE}."FL_19_SINGLE_COURSE_DISC" ;;
  }

  dimension: fl_19_single_course {
    type: string
    sql: ${TABLE}."FL_19_SINGLE_COURSE" ;;
  }

  dimension: fl_19_single_discipline {
    type: string
    sql: ${TABLE}."FL_19_SINGLE_DISCIPLINE" ;;
  }

  dimension: fl_19_single_adoption_key {
    type: string
    sql: ${TABLE}."FL_19_SINGLE_ADOPTION_KEY" ;;
  }

  dimension: fl_19_single_prod_family_cd {
    type: string
    sql: ${TABLE}."FL_19_SINGLE_PROD_FAMILY_CD" ;;
  }

  dimension: fl_19_single_actv_entity_id {
    type: string
    sql: ${TABLE}."FL_19_SINGLE_ACTV_ENTITY_ID" ;;
  }

  dimension: fl_19_single_disc_flg {
    type: number
    sql: ${TABLE}."FL_19_SINGLE_DISC_FLG" ;;
  }

  dimension: sp_19_single_course_disc {
    type: string
    sql: ${TABLE}."SP_19_SINGLE_COURSE_DISC" ;;
  }

  dimension: sp_19_single_course {
    type: string
    sql: ${TABLE}."SP_19_SINGLE_COURSE" ;;
  }

  dimension: sp_19_single_discipline {
    type: string
    sql: ${TABLE}."SP_19_SINGLE_DISCIPLINE" ;;
  }

  dimension: sp_19_single_adoption_key {
    type: string
    sql: ${TABLE}."SP_19_SINGLE_ADOPTION_KEY" ;;
  }

  dimension: sp_19_single_prod_family_cd {
    type: string
    sql: ${TABLE}."SP_19_SINGLE_PROD_FAMILY_CD" ;;
  }

  dimension: sp_19_single_actv_entity_id {
    type: string
    sql: ${TABLE}."SP_19_SINGLE_ACTV_ENTITY_ID" ;;
  }

  dimension: sp_19_single_disc_flg {
    type: number
    sql: ${TABLE}."SP_19_SINGLE_DISC_FLG" ;;
  }

  dimension: all_19_alc_only_flg {
    type: number
    sql: ${TABLE}."ALL_19_ALC_ONLY_FLG" ;;
  }

  dimension: all_19_omitted_cu_user_flg {
    type: number
    sql: ${TABLE}."ALL_19_OMITTED_CU_USER_FLG" ;;
  }

  dimension: fl_19_upsell_flg {
    type: number
    sql: ${TABLE}."FL_19_UPSELL_FLG" ;;
  }

  dimension: sp_19_upsell_flg {
    type: number
    sql: ${TABLE}."SP_19_UPSELL_FLG" ;;
  }

  dimension: all_19_upsell_flg {
    type: number
    sql: ${TABLE}."ALL_19_UPSELL_FLG" ;;
  }

  dimension: cu_to_cu_flg {
    type: number
    sql: ${TABLE}."CU_TO_CU_FLG" ;;
  }

  dimension: cu_to_alc_flg {
    type: number
    sql: ${TABLE}."CU_TO_ALC_FLG" ;;
  }

  dimension: cu_to_nothing_flg {
    type: number
    sql: ${TABLE}."CU_TO_NOTHING_FLG" ;;
  }

  dimension: cu_to_lt_status_flg {
    type: number
    sql: ${TABLE}."CU_TO_LT_STATUS_FLG" ;;
  }

  dimension: alc_to_cu_flg {
    type: number
    sql: ${TABLE}."ALC_TO_CU_FLG" ;;
  }

  dimension: alc_to_alc_flg {
    type: number
    sql: ${TABLE}."ALC_TO_ALC_FLG" ;;
  }

  dimension: alc_to_nothing_flg {
    type: number
    sql: ${TABLE}."ALC_TO_NOTHING_FLG" ;;
  }

  dimension: alc_to_lt_status_flg {
    type: number
    sql: ${TABLE}."ALC_TO_LT_STATUS_FLG" ;;
  }

  dimension: nothing_to_cu_flg {
    type: number
    sql: ${TABLE}."NOTHING_TO_CU_FLG" ;;
  }

  dimension: nothing_to_alc_flg {
    type: number
    sql: ${TABLE}."NOTHING_TO_ALC_FLG" ;;
  }

  dimension: nothing_to_nothing_flg {
    type: number
    sql: ${TABLE}."NOTHING_TO_NOTHING_FLG" ;;
  }

  dimension: nothing_to_lt_status_flg {
    type: number
    sql: ${TABLE}."NOTHING_TO_LT_STATUS_FLG" ;;
  }

  dimension: all_19_pos_cu_spend_flg {
    type: number
    sql: ${TABLE}."ALL_19_POS_CU_SPEND_FLG" ;;
  }

  dimension: all_19_pos_savings_flg {
    type: number
    sql: ${TABLE}."ALL_19_POS_SAVINGS_FLG" ;;
  }

  dimension: bill_to_cust {
    type: string
    sql: ${TABLE}."BILL_TO_CUST" ;;
  }

  dimension: path_type {
    type: string
    sql: ${TABLE}."PATH_TYPE" ;;
  }

  set: detail {
    fields: [
      merged_guid,
      upgrade_source,
      cu_redemption_entity_no,
      fl_19_cu_user_flg,
      fl_19_cu_upgrade_flg,
      fl_19_stud_spd_list,
      fl_19_stud_spd_list_bycu,
      fl_19_stud_ebk_spd_list_bycu,
      fl_19_stud_spd_list_w_ebk_bycu,
      fl_19_stud_ebk_spd_bycu,
      fl_19_ebk_netsls_bycu,
      fl_19_stud_spd,
      fl_19_stud_spd_w_ebk_bycu,
      fl_19_cl_net_sales_value,
      fl_19_cl_net_sales_bycu,
      fl_19_cl_net_sales_w_ebk_bycu,
      fl_19_activation_units,
      fl_19_activation_units_bycu,
      fl_19_actv_units_ebk_bycu,
      fl_19_adop_units_ebk_bycu,
      fl_19_isbn_sub_dur,
      fl_19_sumofdays_paid,
      fl_19_cu_spend,
      fl_19_cu_cl_net_sales,
      fl_19_bkstr_redemp_flg,
      fl_19_ecom_redemp_flg,
      fl_19_pac_flg,
      fl_19_sum_of_matched_redemp,
      sp_19_cu_user_flg,
      sp_19_cu_upgrade_flg,
      sp_19_stud_spd_list,
      sp_19_stud_spd_list_bycu,
      sp_19_stud_ebk_spd_list_bycu,
      sp_19_stud_spd_list_w_ebk_bycu,
      sp_19_stud_ebk_spd_bycu,
      sp_19_ebk_netsls_bycu,
      sp_19_cl_net_sales_w_ebk_bycu,
      sp_19_stud_spd,
      sp_19_stud_spd_w_ebk_bycu,
      sp_19_cl_net_sales_value,
      sp_19_cl_net_sales_bycu,
      sp_19_activation_units,
      sp_19_activation_units_bycu,
      sp_19_actv_units_ebk_bycu,
      sp_19_adop_units_ebk_bycu,
      sp_19_isbn_sub_dur,
      sp_19_sumofdays_paid,
      sp_19_cu_spend,
      sp_19_cu_cl_net_sales,
      sp_19_bkstr_redemp_flg,
      sp_19_ecom_redemp_flg,
      sp_19_pac_flg,
      sp_19_sum_of_matched_redemp,
      max_actv_entity_id_cleansed,
      merged_entity_no,
      all_19_cu_user_flg,
      cu_subscriber_flg,
      all_19_cu_redemp_flg,
      all_19_cu_upgrade_flg,
      all_19_stud_spd_list,
      all_19_stud_ebk_spd_list_bycu,
      all_19_stud_spd_list_bycu,
      all_19_stud_spd_list_w_ebk_bycu,
      all_19_stud_ebk_spd_bycu,
      all_19_ebk_netsls_bycu,
      all_19_stud_spd,
      all_19_cl_net_sales_value,
      all_19_cl_net_sales_bycu,
      all_19_cl_net_sales_w_ebk_bycu,
      all_19_activation_units,
      all_19_activation_units_bycu,
      all_19_actv_units_ebk_bycu,
      all_19_adop_units_ebk_bycu,
      all_19_cu_spend,
      all_19_cu_cl_net_sales,
      all_19_bkstr_redemp_flg,
      all_19_ecom_redemp_flg,
      all_19_pac_flg,
      all_19_sum_of_matched_redemp,
      fl_19_master_sub_dur,
      sp_19_master_sub_dur,
      institution_nm,
      mkt_seg_min_de,
      inst_2_yr_4_yr,
      inst_cui_flg,
      inst_star_rating,
      fl_19_big_spend_bucket,
      sp_19_big_spend_bucket,
      fl_19_big_spd_bckt_w_ebk_bycu,
      sp_19_big_spd_bckt_w_ebk_bycu,
      fl_19_sub_dur_cat,
      sp_19_sub_dur_cat,
      fl_19_renewal_flg,
      sp_19_renewal_flg,
      fl_19_cann_no_ebk,
      sp_19_cann_no_ebk,
      fl_19_cann,
      sp_19_cann,
      fl_19_spend_bucket,
      sp_19_spend_bucket,
      fl_19_savings,
      sp_19_savings,
      fl_19_pos_cu_spend_flg,
      sp_19_pos_cu_spend_flg,
      fl_19_pos_savings_flg,
      sp_19_pos_savings_flg,
      fl_19_alc_only_flg,
      sp_19_alc_only_flg,
      fl_19_nothing_flg,
      sp_19_nothing_flg,
      fl_19_omitted_cu_user_flg,
      sp_19_omitted_cu_user_flg,
      all_19_cann,
      all_19_cann_no_ebk,
      all_19_savings,
      fl_19_takes,
      fl_19_take_opps,
      sp_19_takes,
      sp_19_take_opps,
      all_19_takes,
      all_19_take_opps,
      fl_19_single_course_disc,
      fl_19_single_course,
      fl_19_single_discipline,
      fl_19_single_adoption_key,
      fl_19_single_prod_family_cd,
      fl_19_single_actv_entity_id,
      fl_19_single_disc_flg,
      sp_19_single_course_disc,
      sp_19_single_course,
      sp_19_single_discipline,
      sp_19_single_adoption_key,
      sp_19_single_prod_family_cd,
      sp_19_single_actv_entity_id,
      sp_19_single_disc_flg,
      all_19_alc_only_flg,
      all_19_omitted_cu_user_flg,
      fl_19_upsell_flg,
      sp_19_upsell_flg,
      all_19_upsell_flg,
      cu_to_cu_flg,
      cu_to_alc_flg,
      cu_to_nothing_flg,
      cu_to_lt_status_flg,
      alc_to_cu_flg,
      alc_to_alc_flg,
      alc_to_nothing_flg,
      alc_to_lt_status_flg,
      nothing_to_cu_flg,
      nothing_to_alc_flg,
      nothing_to_nothing_flg,
      nothing_to_lt_status_flg,
      all_19_pos_cu_spend_flg,
      all_19_pos_savings_flg,
      bill_to_cust,
      path_type
    ]
  }

 set: strategy_fields {
  fields:  [
      merged_guid,
      upgrade_source,
      cu_redemption_entity_no,
      fl_19_cu_user_flg,
      fl_19_cu_upgrade_flg,
      fl_19_stud_spd_list,
      fl_19_stud_spd_list_bycu,
      fl_19_stud_ebk_spd_list_bycu,
      fl_19_stud_spd_list_w_ebk_bycu,
      fl_19_stud_ebk_spd_bycu,
      fl_19_ebk_netsls_bycu,
      fl_19_stud_spd,
      fl_19_stud_spd_w_ebk_bycu,
      fl_19_cl_net_sales_value,
      fl_19_cl_net_sales_bycu,
      fl_19_cl_net_sales_w_ebk_bycu,
      fl_19_activation_units,
      fl_19_activation_units_bycu,
      fl_19_actv_units_ebk_bycu,
      fl_19_adop_units_ebk_bycu,
      fl_19_isbn_sub_dur,
      fl_19_sumofdays_paid,
      fl_19_cu_spend,
      fl_19_cu_cl_net_sales,
      fl_19_bkstr_redemp_flg,
      fl_19_ecom_redemp_flg,
      fl_19_pac_flg,
      fl_19_sum_of_matched_redemp,
      sp_19_cu_user_flg,
      sp_19_cu_upgrade_flg,
      sp_19_stud_spd_list,
      sp_19_stud_spd_list_bycu,
      sp_19_stud_ebk_spd_list_bycu,
      sp_19_stud_spd_list_w_ebk_bycu,
      sp_19_stud_ebk_spd_bycu,
      sp_19_ebk_netsls_bycu,
      sp_19_cl_net_sales_w_ebk_bycu,
      sp_19_stud_spd,
      sp_19_stud_spd_w_ebk_bycu,
      sp_19_cl_net_sales_value,
      sp_19_cl_net_sales_bycu,
      sp_19_activation_units,
      sp_19_activation_units_bycu,
      sp_19_actv_units_ebk_bycu,
      sp_19_adop_units_ebk_bycu,
      sp_19_isbn_sub_dur,
      sp_19_sumofdays_paid,
      sp_19_cu_spend,
      sp_19_cu_cl_net_sales,
      sp_19_bkstr_redemp_flg,
      sp_19_ecom_redemp_flg,
      sp_19_pac_flg,
      sp_19_sum_of_matched_redemp,
      max_actv_entity_id_cleansed,
      merged_entity_no,
      all_19_cu_user_flg,
      cu_subscriber_flg,
      all_19_cu_redemp_flg,
      all_19_cu_upgrade_flg,
      all_19_stud_spd_list,
      all_19_stud_ebk_spd_list_bycu,
      all_19_stud_spd_list_bycu,
      all_19_stud_spd_list_w_ebk_bycu,
      all_19_stud_ebk_spd_bycu,
      all_19_ebk_netsls_bycu,
      all_19_stud_spd,
      all_19_cl_net_sales_value,
      all_19_cl_net_sales_bycu,
      all_19_cl_net_sales_w_ebk_bycu,
      all_19_activation_units,
      all_19_activation_units_bycu,
      all_19_actv_units_ebk_bycu,
      all_19_adop_units_ebk_bycu,
      all_19_cu_spend,
      all_19_cu_cl_net_sales,
      all_19_bkstr_redemp_flg,
      all_19_ecom_redemp_flg,
      all_19_pac_flg,
      all_19_sum_of_matched_redemp,
      fl_19_master_sub_dur,
      sp_19_master_sub_dur,
      institution_nm,
      mkt_seg_min_de,
      inst_2_yr_4_yr,
      inst_cui_flg,
      inst_star_rating,
      fl_19_big_spend_bucket,
      sp_19_big_spend_bucket,
      fl_19_big_spd_bckt_w_ebk_bycu,
      sp_19_big_spd_bckt_w_ebk_bycu,
      fl_19_sub_dur_cat,
      sp_19_sub_dur_cat,
      fl_19_renewal_flg,
      sp_19_renewal_flg,
      fl_19_cann_no_ebk,
      sp_19_cann_no_ebk,
      fl_19_cann,
      sp_19_cann,
      fl_19_spend_bucket,
      sp_19_spend_bucket,
      fl_19_savings,
      sp_19_savings,
      fl_19_pos_cu_spend_flg,
      sp_19_pos_cu_spend_flg,
      fl_19_pos_savings_flg,
      sp_19_pos_savings_flg,
      fl_19_alc_only_flg,
      sp_19_alc_only_flg,
      fl_19_nothing_flg,
      sp_19_nothing_flg,
      fl_19_omitted_cu_user_flg,
      sp_19_omitted_cu_user_flg,
      all_19_cann,
      all_19_cann_no_ebk,
      all_19_savings,
      fl_19_takes,
      fl_19_take_opps,
      sp_19_takes,
      sp_19_take_opps,
      all_19_takes,
      all_19_take_opps,
      fl_19_single_course_disc,
      fl_19_single_course,
      fl_19_single_discipline,
      fl_19_single_adoption_key,
      fl_19_single_prod_family_cd,
      fl_19_single_actv_entity_id,
      fl_19_single_disc_flg,
      sp_19_single_course_disc,
      sp_19_single_course,
      sp_19_single_discipline,
      sp_19_single_adoption_key,
      sp_19_single_prod_family_cd,
      sp_19_single_actv_entity_id,
      sp_19_single_disc_flg,
      all_19_alc_only_flg,
      all_19_omitted_cu_user_flg,
      fl_19_upsell_flg,
      sp_19_upsell_flg,
      all_19_upsell_flg,
      cu_to_cu_flg,
      cu_to_alc_flg,
      cu_to_nothing_flg,
      cu_to_lt_status_flg,
      alc_to_cu_flg,
      alc_to_alc_flg,
      alc_to_nothing_flg,
      alc_to_lt_status_flg,
      nothing_to_cu_flg,
      nothing_to_alc_flg,
      nothing_to_nothing_flg,
      nothing_to_lt_status_flg,
      all_19_pos_cu_spend_flg,
      all_19_pos_savings_flg,
      bill_to_cust,
      path_type
    ]
    }
}
