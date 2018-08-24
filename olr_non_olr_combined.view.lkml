view: olr_non_olr_combined {
  derived_table: {
    sql: with orgs as (
        select
            actv_olr_id as activationid
            ,DATE_TRUNC('week', actv_dt) as week
            ,user_guid as user_id
            ,organization
            ,platform
            ,'OLR' as registrationtype
            ,cu_flg
        from stg_clts.activations_olr
        where organization is not null
        and latest
        --and in_actv_flg = 1
        union all
        select
            actv_non_olr_id
            ,DATE_TRUNC('week', actv_dt) as week
            ,UNIQUE_USER_ID AS user_id
            ,organization
            ,platform
            ,'Non_OLR'
            ,cu_flg
        from stg_clts.activations_non_olr
        where organization is not null
        and latest
        --and in_actv_flg = 1
        -- group by 1, 2, 3, 4, 6
      )

      SELECT
        week
        ,user_id
        ,COUNT( activationid)
      FROM orgs
      WHERE cu_flg = 'Y'
      GROUP BY 1, 2
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: week {
    type: date
    sql: ${TABLE}."WEEK" ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: count_activationid {
    type: number
    label: "COUNT( ACTIVATIONID)"
    sql: ${TABLE}."COUNT( ACTIVATIONID)" ;;
  }

  set: detail {
    fields: [week, user_id, count_activationid]
  }
}
