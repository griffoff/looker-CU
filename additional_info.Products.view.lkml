view: additional_info_products {
  derived_table: {
    sql:
        with prod as (

        SELECT user_sso_guid
        ,COUNT(*) AS Total_products
        ,COUNT(DISTINCT product_id) as Provisioned_Product
        ,MIN(TO_DATE(date_added)) AS first_added_date
        ,MAX(TO_DATE(date_added)) AS last_added_date
        ,COUNT(DISTINCT DATE_TRUNC('month',date_added)) AS No_Of_Months_With_Products

  FROM UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT
  group by user_sso_guid
  ) select * from prod  ;;

  # datagroup_trigger: provisioned_product
    }

    dimension: Provisioned_Product {
      type: number
      sql: COALESCE(${TABLE}.Provisioned_Product,0) ;;
    }

    dimension:user_sso_guid  {
      primary_key: yes
    }

    dimension: products_tiered {
      type: tier
      style: integer
      tiers: [1,10,20,30,40,50,60,70,80,90,100]
      sql: ${Provisioned_Product} ;;
    }

  dimension: products_tiered_fair_use {
    type: tier
    style: integer
    tiers: [2,4,6,8,10]
    sql: ${Provisioned_Product} ;;
  }

    dimension: last_added_date {
      type: date
    }

  dimension: first_added_date {
    type: date
  }

    measure: count {
      label: "# Users"
      type: count
    }

  }
