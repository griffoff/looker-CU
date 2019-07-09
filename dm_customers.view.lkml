view: dm_customers {
  sql_table_name: DEV.STRATEGY_SPRING_REVIEW_QUERIES.DM_CUSTOMERS ;;

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

  dimension: business_unit_cd {
    type: number
    sql: ${TABLE}."BUSINESS_UNIT_CD" ;;
  }

  dimension: business_unit_de {
    type: string
    sql: ${TABLE}."BUSINESS_UNIT_DE" ;;
  }

  dimension: buyers_grp_cd {
    type: string
    sql: ${TABLE}."BUYERS_GRP_CD" ;;
  }

  dimension: buyers_grp_de {
    type: string
    sql: ${TABLE}."BUYERS_GRP_DE" ;;
  }

  dimension: chain_school_nm {
    type: string
    sql: ${TABLE}."CHAIN_SCHOOL_NM" ;;
  }

  dimension: chain_school_no {
    type: string
    sql: ${TABLE}."CHAIN_SCHOOL_NO" ;;
  }

  dimension: changed_dt {
    type: string
    sql: ${TABLE}."CHANGED_DT" ;;
  }

  dimension: city_nm {
    type: string
    sql: ${TABLE}."CITY_NM" ;;
  }

  dimension: country_cd {
    type: string
    sql: ${TABLE}."COUNTRY_CD" ;;
  }

  dimension: country_de {
    type: string
    sql: ${TABLE}."COUNTRY_DE" ;;
  }

  dimension: cust_channel_cd {
    type: string
    sql: ${TABLE}."CUST_CHANNEL_CD" ;;
  }

  dimension: cust_channel_de {
    type: string
    sql: ${TABLE}."CUST_CHANNEL_DE" ;;
  }

  dimension: cust_class_cd {
    type: string
    sql: ${TABLE}."CUST_CLASS_CD" ;;
  }

  dimension: cust_class_de {
    type: string
    sql: ${TABLE}."CUST_CLASS_DE" ;;
  }

  dimension: cust_fax {
    type: string
    sql: ${TABLE}."CUST_FAX" ;;
  }

  dimension: cust_grandparent_no {
    type: number
    sql: ${TABLE}."CUST_GRANDPARENT_NO" ;;
  }

  dimension: cust_nm {
    type: string
    sql: ${TABLE}."CUST_NM" ;;
  }

  dimension: cust_no {
    type: number
    sql: ${TABLE}."CUST_NO" ;;
  }

  dimension: cust_parent_no {
    type: number
    sql: ${TABLE}."CUST_PARENT_NO" ;;
  }

  dimension: cust_phone_no {
    type: string
    sql: ${TABLE}."CUST_PHONE_NO" ;;
  }

  dimension: cust_status_cd {
    type: string
    sql: ${TABLE}."CUST_STATUS_CD" ;;
  }

  dimension: cust_status_de {
    type: string
    sql: ${TABLE}."CUST_STATUS_DE" ;;
  }

  dimension: custom_pub_terr_cd {
    type: string
    sql: ${TABLE}."CUSTOM_PUB_TERR_CD" ;;
  }

  dimension: custom_pub_terr_de {
    type: string
    sql: ${TABLE}."CUSTOM_PUB_TERR_DE" ;;
  }

  dimension: customer_price_group_cd {
    type: string
    sql: ${TABLE}."CUSTOMER_PRICE_GROUP_CD" ;;
  }

  dimension: customer_price_group_de {
    type: string
    sql: ${TABLE}."CUSTOMER_PRICE_GROUP_DE" ;;
  }

  dimension: entity_no {
    type: number
    sql: ${TABLE}."ENTITY_NO" ;;
  }

  dimension: est_enrollment {
    type: string
    sql: ${TABLE}."EST_ENROLLMENT" ;;
  }

  dimension: gsf_special_cd {
    type: string
    sql: ${TABLE}."GSF_SPECIAL_CD" ;;
  }

  dimension: gsf_special_de {
    type: string
    sql: ${TABLE}."GSF_SPECIAL_DE" ;;
  }

  dimension: mdr_pop_served {
    type: string
    sql: ${TABLE}."MDR_POP_SERVED" ;;
  }

  dimension: mkt_seg_grp_cd {
    type: string
    sql: ${TABLE}."MKT_SEG_GRP_CD" ;;
  }

  dimension: mkt_seg_grp_de {
    type: string
    sql: ${TABLE}."MKT_SEG_GRP_DE" ;;
  }

  dimension: mkt_seg_maj_cd {
    type: string
    sql: ${TABLE}."MKT_SEG_MAJ_CD" ;;
  }

  dimension: mkt_seg_maj_de {
    type: string
    sql: ${TABLE}."MKT_SEG_MAJ_DE" ;;
  }

  dimension: mkt_seg_min_cd {
    type: string
    sql: ${TABLE}."MKT_SEG_MIN_CD" ;;
  }

  dimension: mkt_seg_min_de {
    type: string
    sql: ${TABLE}."MKT_SEG_MIN_DE" ;;
  }

  dimension: mkt_seg_pub_def_cd {
    type: number
    sql: ${TABLE}."MKT_SEG_PUB_DEF_CD" ;;
  }

  dimension: mkt_seg_pub_def_de {
    type: string
    sql: ${TABLE}."MKT_SEG_PUB_DEF_DE" ;;
  }

  dimension: postal_code {
    type: string
    sql: ${TABLE}."POSTAL_CODE" ;;
  }

  dimension: previous_id {
    type: string
    sql: ${TABLE}."PREVIOUS_ID" ;;
  }

  dimension: state_cd {
    type: string
    sql: ${TABLE}."STATE_CD" ;;
  }

  dimension: state_de {
    type: string
    sql: ${TABLE}."STATE_DE" ;;
  }

  dimension: street_1_ad {
    type: string
    sql: ${TABLE}."STREET_1_AD" ;;
  }

  dimension: street_2_ad {
    type: string
    sql: ${TABLE}."STREET_2_AD" ;;
  }

  dimension: street_3_ad {
    type: string
    sql: ${TABLE}."STREET_3_AD" ;;
  }

  dimension: street_4_ad {
    type: string
    sql: ${TABLE}."STREET_4_AD" ;;
  }

  dimension: territory_class_cd {
    type: string
    sql: ${TABLE}."TERRITORY_CLASS_CD" ;;
  }

  dimension: territory_class_de {
    type: string
    sql: ${TABLE}."TERRITORY_CLASS_DE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
