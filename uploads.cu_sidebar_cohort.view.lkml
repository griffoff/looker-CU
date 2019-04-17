view: uploads_cu_sidebar_cohort {
  label: "Learner Profile"
    derived_table: {
      sql: --select * from uploads.cu.cu_sidebar_cohort where cu_sso_guid is not null and pilot is not null
         with shadow as (
        SELECT
      partner_guid AS shadow_guid
      ,ANY_VALUE(primary_guid) AS primary_guid
            FROM prod.UNLIMITED.VW_PARTNER_TO_PRIMARY_USER_GUID
                WHERE partner_guid IS NOT NULL
                AND primary_guid IS NOT NULL
            GROUP BY 1
        ) select distinct COALESCE(s.primary_guid,sd.cu_sso_guid) merged, sd.*
                from uploads.cu.cu_sidebar_cohort sd
            left join shadow s on sd.cu_sso_guid = s.shadow_guid
            and cu_sso_guid is not null

        ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }
    dimension: merged  {
      hidden: yes
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

    dimension: pilot {
      type: string
      sql: ${TABLE}."PILOT" ;;
    }

    dimension: source {
      type: string
      sql: ${TABLE}."SOURCE" ;;
      hidden: yes
    }

    dimension: cu_sso_guid {
      type: string
      sql: ${TABLE}."CU_SSO_GUID" ;;
      hidden: yes
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
        pilot,
        source,
        cu_sso_guid,
        _fivetran_synced_time
      ]
    }


  }
