explore: session_products {}
view: session_products {
  sql_table_name: prod.cu_user_analysis.session_products ;;

  dimension: session_id {hidden: yes type: number}

  dimension_group: session_start {
    hidden: yes
    type:time
    timeframes: [raw,time]
    }

  dimension: user_sso_guid {hidden: yes}

  dimension: user_products_isbn {hidden: yes}

  dimension: course_key {hidden: yes}

  dimension: session_product_id {hidden: yes primary_key: yes type: number}
}
