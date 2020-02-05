explore: al_cu_activations {}

view: al_cu_activations {
  derived_table: {
    sql: SELECT * FROM uploads.cu.al_cu_activations
      ;;
  }


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
    hidden: yes
  }

  dimension: _fivetran_deleted {
    type: string
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
    hidden: yes
  }

  dimension: item_de {
    type: string
    sql: ${TABLE}."ITEM_DE" ;;
  }

  dimension: print_digital_config_cd {
    type: number
    sql: ${TABLE}."PRINT_DIGITAL_CONFIG_CD" ;;
  }

  dimension: division_de {
    type: string
    sql: ${TABLE}."DIVISION_DE" ;;
  }

  dimension: pub_series_cd {
    type: string
    sql: ${TABLE}."PUB_SERIES_CD" ;;
  }

  dimension: publ_grp_cd {
    type: string
    sql: ${TABLE}."PUBL_GRP_CD" ;;
  }

  dimension: course_de {
    type: string
    sql: ${TABLE}."COURSE_DE" ;;
  }

  dimension: prod_family_cd {
    type: string
    sql: ${TABLE}."PROD_FAMILY_CD" ;;
  }

  dimension: media_type_cd {
    type: string
    sql: ${TABLE}."MEDIA_TYPE_CD" ;;
  }

  dimension: tech_prod_cd_de {
    type: string
    sql: ${TABLE}."TECH_PROD_CD_DE" ;;
  }

  dimension: custom_pub_flg {
    type: string
    sql: ${TABLE}."CUSTOM_PUB_FLG" ;;
  }

  dimension: edition {
    type: number
    sql: ${TABLE}."EDITION" ;;
  }

  dimension: cu_activations {
    type: number
    sql: ${TABLE}."CU_ACTIVATIONS" ;;
  }

  dimension: item_cd {
    type: string
    sql: ${TABLE}."ITEM_CD" ;;
  }

  dimension: print_digital_config_de {
    type: string
    sql: ${TABLE}."PRINT_DIGITAL_CONFIG_DE" ;;
  }

  dimension: division_cd {
    type: number
    sql: ${TABLE}."DIVISION_CD" ;;
  }

  dimension: pub_series_de {
    type: string
    sql: ${TABLE}."PUB_SERIES_DE" ;;
  }

  dimension: copyright_yr {
    type: number
    sql: ${TABLE}."COPYRIGHT_YR" ;;
  }

  dimension: consumed_isbn {
    type: number
    sql: ${TABLE}."CONSUMED_ISBN" ;;
  }

  dimension: tech_prod_cd {
    type: string
    sql: ${TABLE}."TECH_PROD_CD" ;;
  }

  dimension: publ_grp_de {
    type: string
    sql: ${TABLE}."PUBL_GRP_DE" ;;
  }

  dimension: course_cd {
    type: string
    sql: ${TABLE}."COURSE_CD" ;;
  }

  dimension: prod_family_de {
    type: string
    sql: ${TABLE}."PROD_FAMILY_DE" ;;
  }

  dimension: media_type_de {
    type: string
    sql: ${TABLE}."MEDIA_TYPE_DE" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension: indigenous_flg {
    type: string
    sql: ${TABLE}."INDIGENOUS_FLG" ;;
  }

  dimension: business_unit_cd {
    type: number
    sql: ${TABLE}."BUSINESS_UNIT_CD" ;;
  }

  dimension: fiscal_year {
    type: number
    sql: ${TABLE}."FISCAL_YEAR" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
    hidden: yes
  }

  set: detail {
    fields: [
      _row,
      _fivetran_deleted,
      item_de,
      print_digital_config_cd,
      division_de,
      pub_series_cd,
      publ_grp_cd,
      course_de,
      prod_family_cd,
      media_type_cd,
      tech_prod_cd_de,
      custom_pub_flg,
      edition,
      cu_activations,
      item_cd,
      print_digital_config_de,
      division_cd,
      pub_series_de,
      copyright_yr,
      consumed_isbn,
      tech_prod_cd,
      publ_grp_de,
      course_cd,
      prod_family_de,
      media_type_de,
      title,
      indigenous_flg,
      business_unit_cd,
      fiscal_year,
      _fivetran_synced_time
    ]
  }
}
