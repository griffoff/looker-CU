explore: week_to_week_sankey {}

view: week_to_week_sankey {
    derived_table: {
      explore_source: usage_by_week {
        column: user_sso_guid {}
        column: event_week {}
        column: usage_classification {}
        derived_column: week_0 {sql: usage_classification;;}
        derived_column: week_1 {sql: LEAD(usage_classification) OVER (PARTITION BY user_sso_guid ORDER BY event_week);;}
        derived_column: week_2 {sql: LEAD(usage_classification, 2) OVER (PARTITION BY user_sso_guid ORDER BY event_week);;}
        derived_column: week_3 {sql: LEAD(usage_classification, 3) OVER (PARTITION BY user_sso_guid ORDER BY event_week);;}
        derived_column: week_4 {sql: LEAD(usage_classification, 4) OVER (PARTITION BY user_sso_guid ORDER BY event_week);;}
        derived_column: week_5 {sql: LEAD(usage_classification, 5) OVER (PARTITION BY user_sso_guid ORDER BY event_week);;}
        derived_column: week_6 {sql: LEAD(usage_classification, 6) OVER (PARTITION BY user_sso_guid ORDER BY event_week);;}
        derived_column: week_7 {sql: LEAD(usage_classification, 7) OVER (PARTITION BY user_sso_guid ORDER BY event_week);;}
        derived_column: week_8 {sql: LEAD(usage_classification, 8) OVER (PARTITION BY user_sso_guid ORDER BY event_week);;}
        derived_column: week_9 {sql: LEAD(usage_classification, 9) OVER (PARTITION BY user_sso_guid ORDER BY event_week);;}
        derived_column: week_10 {sql: LEAD(usage_classification, 10) OVER (PARTITION BY user_sso_guid ORDER BY event_week);;}
      }
    }
    dimension: user_sso_guid {
      label: "Usage By Week User Events User SSO GUID"
    }
    dimension: event_week {
      label: "Usage By Week User Events Event timestamp UTC Week"
      description: "Components of the events timestamp stored in TZ format"
      type: date_week
    }
  dimension: week_0 {
    type: string
  }

  dimension: week_1 {
    type: string
  }

  dimension: week_2 {
    type: string
  }

  dimension: week_3 {
    type: string
  }

  dimension: week_4 {
    type: string
  }

  dimension: week_5 {
    type: string
  }

  dimension: week_6 {
    type: string
  }

  dimension: week_7 {
    type: string
  }

  dimension: week_8 {
    type: string
  }

  dimension: week_9 {
    type: string
  }

  dimension: week_10 {
    type: string
  }

  measure: count {
    type:  count
  }

  }
