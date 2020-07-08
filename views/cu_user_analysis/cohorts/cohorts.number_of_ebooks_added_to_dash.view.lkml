include: "cohorts.base.view"

view: cohorts_number_of_ebooks_added_dash {
    extends: [cohorts_base_number]
    derived_table: {
      sql:
      WITH
    term_dates AS
    (
      SELECT
        governmentdefinedacademicterm
        ,1 AS groupbyhack
        ,MIN(datevalue) AS start_date
        ,MAX(datevalue) AS end_date
      FROM prod.dw_ga.dim_date
      WHERE governmentdefinedacademicterm IS NOT NULL
      GROUP BY 1
      ORDER BY 4 DESC
    )
    ,term_dates_most_recent AS
    (
        SELECT
          RANK() OVER (ORDER BY start_date DESC) AS terms_chron_order_desc
          ,*
        FROM term_dates
        WHERE start_date < CURRENT_DATE()
        ORDER BY terms_chron_order_desc
        LIMIT 5
    )
    ,number_of_ebooks_on_dash AS
    (
    SELECT
           pp.user_sso_guid
           ,terms_chron_order_desc
           ,governmentdefinedacademicterm
           ,COUNT(DISTINCT CASE WHEN pp.context_id IS NOT NULL THEN pp.iac_isbn END) AS number_of_courseware_on_dashboard
           ,COUNT(DISTINCT CASE WHEN pp.context_id IS NULL THEN pp.iac_isbn END) AS number_of_ebooks_on_dashboard
    FROM term_dates_most_recent d
    LEFT JOIN olr.prod.provisioned_product pp
           ON pp.date_added::DATE >= d.start_date AND pp.date_added <= d.end_date
    GROUP BY 1, 2, 3
    )
   ,number_of_ebooks_on_dash_pivoted AS
    (
    SELECT
        *
    FROM number_of_ebooks_on_dash
    PIVOT (SUM(number_of_ebooks_on_dashboard) FOR terms_chron_order_desc IN (1, 2, 3, 4, 5))
    )
    SELECT
      user_sso_guid
      ,SUM(CASE WHEN "1" > 0 THEN "1" ELSE 0 END) AS "1"
      ,SUM(CASE WHEN "2" > 0 THEN "2" ELSE 0 END) AS "2"
      ,SUM(CASE WHEN "3" > 0 THEN "3" ELSE 0 END) AS "3"
      ,SUM(CASE WHEN "4" > 0 THEN "4" ELSE 0 END) AS "4"
      ,SUM(CASE WHEN "5" > 0 THEN "5" ELSE 0 END) AS "5"
    FROM number_of_ebooks_on_dash_pivoted
    GROUP BY 1
                    ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
      hidden: yes
    }

    dimension: user_sso_guid {
      type: string
      sql: ${TABLE}."USER_SSO_GUID" ;;
      hidden: yes
    }

    dimension: governmentdefinedacademicterm {
      type: string
      sql: ${TABLE}."GOVERNMENTDEFINEDACADEMICTERM" ;;
    }

    dimension: current { group_label: "# of ebook on dashboard" hidden: no description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

    dimension: minus_1 { group_label: "# of ebook on dashboard" hidden: no description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

    dimension: minus_2 { group_label: "# of ebook on dashboard" hidden: no description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

    dimension: minus_3 { group_label: "# of ebook on dashboard" hidden: no description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

    dimension: minus_4 { group_label: "# of ebook on dashboard" hidden: no description: "Terms: Spr Jan-Jun, Sum Jul, Fall Aug-Dec"}

#   dimension: current_tiers_times {
#     group_label: "# of ebook on dashboard (tiers)"
#     hidden: no
#   }
#
#   dimension: minus_1_tiers_times {
#     group_label: "# of ebook on dashboard (tiers)"
#     hidden: no
#   }
#
  }
