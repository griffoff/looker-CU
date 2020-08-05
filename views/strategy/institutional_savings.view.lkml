explore: institutional_savings {hidden:yes}
view: institutional_savings {

  derived_table: {

  sql: with total_students as (
        select count(distinct user_sso_guid) as total_stud,oc.entity_no from prod.cu_user_analysis.user_courses uc
        left join prod.stg_clts.olr_courses oc
              ON uc.olr_course_key = oc.course_key
        where cu_subscription_id IS NOT NULL AND to_date(course_start_date) > '2019-01-01'
        group by 2
      ),
      entity_dt as (
        Select uc.*,oc.ENTITY_NO,oc.course_name as course_names
      from prod.cu_user_analysis.user_courses uc
      left join prod.stg_clts.olr_courses oc
      --ON uc.olr_course_key = oc."#CONTEXT_ID"
      ON uc.olr_course_key = oc.course_key
      WHERE enrolled OR activated AND to_date(oc.begin_date) > '2019-01-01'

      ) --Select *,row_number() over (partition by entity_no order by no_students desc) as row_num  from entity_dt limit 10;
      , stu_course as(
        select
        entity_no,
        course_names,
        Count (distinct user_sso_guid) AS no_students
        from entity_dt group by 1,2
        ) ,row_no as (Select entity_no,course_names,row_number() over (partition by entity_no order by no_students desc) as ro_nu from stu_course

        ),final_pivot as ( select entity_no, "1" as Top_course_1,"2" as Top_course_2,"3" as Top_course_3
            from row_no
          PIVOT (MAx(course_names) FOR ro_nu IN (1,2,3)) as P
          )

          Select p.Top_course_1,p.Top_course_2,p.Top_course_3,s.total_stud, int_sav.*
          from final_pivot p
          LEFT JOIN total_students s
          ON p.entity_no = s.entity_no
          LEFT JOIN UPLOADS.cu.institution_savings int_sav
          ON int_sav.entity_no = p.entity_no
    ;;

    persist_for: "12 hours"
  }

  set: marketing_fields {fields:[student_savings_courseware_ebook_chegg_,average_savings_per_subscriber_who_saved,Top_course_1,Top_course_2,Top_course_3,total_stud]}

  measure: count {
    type: count
    drill_fields: [detail*]
    hidden: yes
  }

  dimension: entity_no {
    type: number
    sql: ${TABLE}."ENTITY_NO" ;;
    hidden: yes
  }

  dimension: Top_course_1{hidden: yes}
  dimension: Top_course_2{hidden: yes}
  dimension: Top_course_3{hidden: yes}

  dimension: total_stud{
    label: "# Subscribers per school"
    description: "based on activations contract id till summer'19 "
    hidden: yes
  }


  dimension: institution_nm {
    type: string
    sql: ${TABLE}."INSTITUTION_NM" ;;
    hidden: yes
  }

  dimension: on_map_entity_list_ {
    type: string
    sql: ${TABLE}."ON_MAP_ENTITY_LIST_" ;;
    hidden: yes
  }

  dimension: subscribers {
    type: string
    sql: ${TABLE}."SUBSCRIBERS" ;;
    hidden: yes
  }

  dimension: student_savings_courseware_ebook_chegg_ {
    label: "Institutional Savings"
    description: "Total Savings based on courseware,ebook & chegg calculations done by strategy team. Based off CU subscriptions till Spring 2019 semester. Please Note - This is ONE TIME Feed "
    type: string
    sql: ${TABLE}."STUDENT_SAVINGS_COURSEWARE_EBOOK_CHEGG_" ;;
    hidden: yes
  }

  dimension: average_savings_per_subscription {
    type: string
    sql: ${TABLE}."AVERAGE_SAVINGS_PER_SUBSCRIPTION" ;;
    hidden: yes
  }

  dimension: average_savings_per_subscriber_who_saved {
    type: string
    sql: ${TABLE}."AVERAGE_SAVINGS_PER_SUBSCRIBER_WHO_SAVED" ;;
    hidden: yes
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
    hidden: yes
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
