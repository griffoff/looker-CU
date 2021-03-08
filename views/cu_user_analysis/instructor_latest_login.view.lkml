explore: instructor_latest_login {hidden: yes}

view: instructor_latest_login {

  derived_table: {
    sql:
      WITH created AS (
          SELECT user_sso_guid, MIN(event_time) AS created
          FROM iam.prod.user_mutation
          GROUP BY 1
      )
      SELECT c.user_sso_guid, created.created, MAX(event_time) AS latest_login, MIN(event_time) AS first_login
      FROM iam.prod.credentials_used c
           INNER JOIN prod.datavault.hub_user hu ON c.user_sso_guid = hu.uid
           INNER JOIN prod.datavault.sat_user_v2 su ON hu.hub_user_key = su.hub_user_key AND su._latest
           INNER JOIN created USING (user_sso_guid)
      WHERE su.instructor
      GROUP BY 1, 2
  ;;

  persist_for: "24 hours"
  }

  dimension: user_sso_guid {}
  dimension_group: created {type:time sql:CASE WHEN ${TABLE}.created <= ${TABLE}.first_login THEN ${TABLE}.created END;; }
  dimension_group: latest_login {type:time}
  dimension_group: first_login {type:time}
  dimension_group: since_last_login {
    type:duration
    sql_start: ${latest_login_raw} ;;
    sql_end:  CURRENT_DATE();;
    }

 }
