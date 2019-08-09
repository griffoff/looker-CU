explore: institutional_savings {}
view: institutional_savings {
  derived_table: {
#     sql: Select * from UPLOADS.cu.institution_savings
#       ;;

    sql: with entity_dt as (
  Select uc.*,oc.ENTITY_NO,p.coursearea,p.coursearea_pt,coalesce(p.coursearea,pp.discipline_de) as course_area,pp.discipline_de
from prod.cu_user_analysis.user_courses uc
left join prod.stg_clts.olr_courses oc
--ON uc.olr_course_key = oc."#CONTEXT_ID"
ON uc.olr_course_key = oc.course_key
left join prod.dw_ga.dim_product p
ON uc.isbn = p.isbn13
left join prod.stg_clts.products pp
ON uc.isbn = pp.isbn13
WHERE enrolled OR activated

) --Select *,row_number() over (partition by entity_no order by no_students desc) as row_num  from entity_dt limit 10;

, rows_no as(
  select Count (distinct user_sso_guid) as no_students, entity_no, course_area,
  row_number() over (partition by entity_no order by no_students desc) as row_num --213268
  from entity_dt group by 2,3
  order by 1 desc
  ) ,top_courses as(select array_agg(course_area) as top_courses,entity_no from rows_no
  where row_num <=3  group by entity_no
  )select int_sav.*,t.top_courses from
  UPLOADS.cu.institution_savings int_sav
  LEFT JOIN top_courses t
  ON int_sav.entity_no = t.entity_no
   ;;
  }
  set: marketing_fields {fields:[student_savings_courseware_ebook_chegg_,average_savings_per_subscriber_who_saved,top_courses]}

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: entity_no {
    type: number
    sql: ${TABLE}."ENTITY_NO" ;;
  }

  dimension: top_courses{}

  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
  }

  dimension: on_map_entity_list_ {
    type: string
    sql: ${TABLE}."ON_MAP_ENTITY_LIST_" ;;
  }

  dimension: subscribers {
    type: string
    sql: ${TABLE}."SUBSCRIBERS" ;;
  }

  dimension: student_savings_courseware_ebook_chegg_ {
    label: "Institutional Savings"
    description: "Total Savings based on courseware,ebook & chegg calculations done by strategy team. Based off CU subscriptions till Spring 2019 semester. Please Note - This is ONE TIME Feed "
    type: string
    sql: ${TABLE}."STUDENT_SAVINGS_COURSEWARE_EBOOK_CHEGG_" ;;
  }

  dimension: average_savings_per_subscription {
    type: string
    sql: ${TABLE}."AVERAGE_SAVINGS_PER_SUBSCRIPTION" ;;
  }

  dimension: average_savings_per_subscriber_who_saved {
    type: string
    sql: ${TABLE}."AVERAGE_SAVINGS_PER_SUBSCRIBER_WHO_SAVED" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  set: detail {
    fields: [
      entity_no,
      institution_nm,
      on_map_entity_list_,
      subscribers,
      student_savings_courseware_ebook_chegg_,
      average_savings_per_subscription,
      average_savings_per_subscriber_who_saved,
      _fivetran_synced_time
    ]
  }
}
