view: additional_info_products {
  derived_table: {
    sql:
        with prod as (

        SELECT user_sso_guid, iac.pp_product_type
        ,COUNT(*) AS Total_products
        ,COUNT(DISTINCT prod.product_id) as Provisioned_Product
        ,MIN(TO_DATE(prod.date_added)) AS first_added_date
        ,MAX(TO_DATE(prod.date_added)) AS last_added_date
        ,COUNT(DISTINCT DATE_TRUNC('month',prod.date_added)) AS No_Of_Months_With_Products

  FROM UNLIMITED.RAW_OLR_PROVISIONED_PRODUCT prod
  JOIN PROD.UNLIMITED.RAW_OLR_EXTENDED_IAC Iac
                ON iac.pp_pid = prod.product_id
                  AND prod.user_type like 'student'
                  AND prod."source" like 'unlimited'
  group by user_sso_guid,iac.pp_product_type
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

    dimension: pp_product_type {

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
