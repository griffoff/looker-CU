explore: Fall_Review_FY21  {}


view: Fall_Review_FY21 {
sql_table_name:  strategy.adoption_pivot_FY21_v1.fy21_summerfall_pivot ;;


  dimension: ADOPTION_KEY {}
  dimension: OLD_ADOPTION_KEY {}
  dimension: INSTITUTION_NM {}
  dimension: STATE_CD {}
  dimension: COURSE_CD_DE {}
  dimension: PUB_SERIES_DE {}
  dimension: FY18_ADOPTION_TYPE {}
  dimension: FY19_ADOPTION_TYPE {}
  dimension: FY20_ADOPTION_TYPE {}
  dimension: FY21_ADOPTION_TYPE {}
  dimension: GROWTH_18_19 {}
  dimension: GROWTH_19_20 {}
  dimension: GROWTH_20_21 {}
  dimension: GROWTH_CLASS_18_19 {}
  dimension: GROWTH_CLASS_19_20 {}
  dimension: GROWTH_CLASS_20_21 {}
  dimension: FY18_FY19_ADOPTIONS_TRANSITION_TYPE {}
  dimension: FY19_FY20_ADOPTIONS_TRANSITION_TYPE {}
  dimension: FY20_FY21_ADOPTIONS_TRANSITION_TYPE {}
  dimension: adopt_type_18_19 {}
  dimension: adopt_type_19_20 {}
  dimension: adopt_type_20_21 {}
  #dimension: adopt_type_18_19(rolled) {}
  #dimension: adopt_type_19_20(rolled) {}
  #dimension: adopt_type_20_21(rolled) {}
  dimension: fy19_ia_flg {}
  dimension: fy20_ia_flg {}
  dimension: fy21_ia_flg {}
  dimension: fy19_cui_flg {}
  dimension: fy20_cui_flg {}
  dimension: fy21_cui_flg {}
  dimension: fy19_highia_flg {}
  dimension: fy20_highia_flg {}
  dimension: fy21_highia_flg {}
  dimension: fy19_cumix_seg {}
  dimension: fy20_cumix_seg {}
  dimension: fy21_cumix_seg {}
  dimension: fy19_acct_seg {}
  dimension: fy20_acct_seg {}
  dimension: fy21_acct_seg {}

  measure: FY18_TOTAL_EBOOK_ACTIVATIONS  {
    description: "total eBook activations FY18"
    type: sum
  }

  measure: FY19_TOTAL_EBOOK_ACTIVATIONS  {
    description: "total eBook activations FY18"
    type: sum
  }

  measure: FY20_TOTAL_EBOOK_ACTIVATIONS  {
    description: "total eBook activations FY18"
    type: sum
  }

  measure: FY21_TOTAL_EBOOK_ACTIVATIONS  {
    description: "total eBook activations FY18"
    type: sum
  }


  measure: NONPROV_EBOOK_ACT18  {
    description: "Alacarte eBook FY18"
    type: sum
  }

  measure: NONPROV_EBOOK_ACT19  {
    description: "Alacarte eBook FY19"
    type: sum
  }

  measure: NONPROV_EBOOK_ACT20  {
    description: "Alacarte eBook FY20"
    type: sum
  }

  measure: NONPROV_EBOOK_ACT21  {
    description: "Alacarte eBook FY21"
    type: sum
  }

  measure: CU_PROVISION_EBOOK_FY18  {
    description: "CU eBook FY18"
    type: sum
  }

  measure: CU_PROVISION_EBOOK_FY19  {
    description: "CU eBook FY19"
    type: sum
  }

  measure: CU_PROVISION_EBOOK_FY20  {
    description: "CU eBook FY20"
    type: sum
  }

  measure: CU_PROVISION_EBOOK_FY21  {
    description: "CU eBook FY21"
    type: sum
  }

  measure: CUE_PROVISION_EBOOK_FY18  {
    description: "CU-e eBook FY18"
    type: sum
  }

  measure: CUE_PROVISION_EBOOK_FY19  {
    description: "CU-e eBook FY19"
    type: sum
  }

  measure: CUE_PROVISION_EBOOK_FY20  {
    description: "CU-e eBook FY20"
    type: sum
  }

  measure: CUE_PROVISION_EBOOK_FY21  {
    description: "CU-e eBook FY21"
    type: sum
  }

  measure: TOTAL_CD_ACTV_FY18  {
    description: "FY18 Total Activations"
    type: sum
  }

  measure: TOTAL_CD_ACTV_FY19  {
    description: "FY19 Total Activations"
    type: sum
  }

  measure: TOTAL_CD_ACTV_FY20  {
    description: "FY20 Total Activations"
    type: sum
  }

  measure: TOTAL_CD_ACTV_FY21  {
    description: "FY21 Total Activations"
    type: sum
  }

  measure: TOTAL_CD_ACTV_EXCU_FY18  {
    description: "FY18 Alacarte Activations"
    type: sum
  }

  measure: TOTAL_CD_ACTV_EXCU_FY19  {
    description: "FY19 Alacarte Activations"
    type: sum
  }

  measure: TOTAL_CD_ACTV_EXCU_FY20  {
    description: "FY20 Alacarte Activations"
    type: sum
  }

  measure: TOTAL_CD_ACTV_EXCU_FY21  {
    description: "FY21 Alacarte Activations"
    type: sum
  }


  measure: TOTAL_CD_ACTV_WITHCU_FY18 {
    description: "FY18 CU Activations"
    type: sum
  }

  measure: TOTAL_CD_ACTV_WITHCU_FY19 {
    description: "FY19 CU Activations"
    type: sum
  }

  measure: TOTAL_CD_ACTV_WITHCU_FY20 {
    description: "FY20 CU Activations"
    type: sum
  }

  measure: TOTAL_CD_ACTV_WITHCU_FY21 {
    description: "FY21 CU Activations"
    type: sum
  }

  measure: fy18_total_units  {
    description: "total Unit turnover in FY18"
    type: sum
  }

  measure: fy19_total_units  {
    description: "total Unit turnover in FY19"
    type: sum
  }


  measure: fy20_total_units  {
  description: "total Unit turnover in FY20"
  type: sum
  }

  measure: fy21_total_units  {
    description: "total Unit turnover in FY21"
    type: sum
  }



}  # last squiggly
