# explore: mt_courses_gcs_setup_status {}
view: mt_courses_gcs_setup_status {
  derived_table: {
    sql: WITH
      users AS (
        SELECT
          *
        FROM "MINDTAP"."PROD_NB"."USER"
        WHERE email NOT LIKE '%cengage.com'
        AND email NOT LIKE '%CENGAGE.COM'
        AND email NOT LIKE '%Cengage.com'
        AND email NOT LIKE '%qait.com'
        AND email NOT LIKE '%qai.com'
        AND email NOT LIKE '%testaccount.com'
        AND email NOT LIKE '%development%'
        AND email NOT LIKE '%cengage1.com'
        AND email NOT LIKE '%@nelson.com'
        AND email NOT LIKE '%qaitest.com'
        AND email NOT LIKE '%qaittest.com'
        AND email NOT LIKE '%@swlearning.com'
        AND email NOT LIKE '%@lunarlogic.com'
        AND email NOT LIKE '%@mtx.com'
        AND email NOT LIKE '%@mtxqa.com'
        AND email NOT LIKE '%@henley.com'
        AND email NOT LIKE '%@cengagetest.com'
        AND email NOT LIKE '%@concentricsky.com'
        AND email NOT LIKE '%@test.com'
        AND email NOT LIKE '%@ng.com'
        AND email NOT LIKE '%@qa4u.com'
        AND email NOT LIKE '%@aplia.com'
        AND email NOT LIKE '%@qainfotech.net'
        AND email NOT IN ('cengage.pairing@ultimatemedical.edu','inst1_gateway_130514@yahoo.com','01_gtwy_instructor_30042015@gmail.com','i1_instructor_16052014@gmail.com','i9_instructor_040814@gmail.com','i19_instructor_091014@gmail.com')
        AND source_name NOT IN ('CENGAGE SALES 2009','SOUTHWESTERN PUBLISHING CO.','NOT FOUND')
      )
      SELECT
          O2.NAME AS Institution
          ,S.ID AS SNAPSHOT_ID
          ,S.PARENT_ID
          ,S.SOURCE_ID
          ,S.ISBN
          ,S.CORE_TEXT_ISBN
          ,O1.ID AS ORG_ID
          ,O1.EXTERNAL_ID AS COURSE_KEY
          ,S.BRANDING_DISCIPLINE
          ,C.GCS_STATUS
          ,IFF(S.SOURCE_ID=S.PARENT_ID,'NEW COURSE','COPIED') AS COURSE_CREATION_TYPE
          ,U.FNAME AS Instructor_First_Name
          ,U.LNAME AS Instructor_Last_Name
          ,U.EMAIL AS Instructor_EMAIL
          ,U.SOURCE_ID AS Instructor_GUID
          ,DATE_TRUNC('month', TO_TIMESTAMP_NTZ(TO_DECIMAL(o1.created_date/1000))::DATE) AS created_at
      FROM mindtap.prod_nb.SNAPSHOT S
      JOIN USERS U ON S.CREATED_BY=U.ID
      JOIN mindtap.prod_nb.ORG O1 ON S.ORG_ID=O1.ID
      JOIN mindtap.prod_nb.ORG O2 ON O1.PARENT_ID = O2.ID
      JOIN mindtap.prod_nb.COURSE C ON C.ORG_ID=O1.ID
      WHERE TO_TIMESTAMP_NTZ(TO_DECIMAL(o1.created_date/1000))::DATE >= '2018-08-01'
      AND TO_TIMESTAMP_NTZ(TO_DECIMAL(o1.created_date/1000))::DATE <= '2019-09-30'
      AND C.GCS_STATUS IS NOT NULL
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: institution {
    type: string
    sql: ${TABLE}."INSTITUTION" ;;
  }

  dimension: snapshot_id {
    type: number
    sql: ${TABLE}."SNAPSHOT_ID" ;;
  }

  dimension: parent_id {
    type: number
    sql: ${TABLE}."PARENT_ID" ;;
  }

  dimension: source_id {
    type: number
    sql: ${TABLE}."SOURCE_ID" ;;
  }

  dimension: isbn {
    type: string
    sql: ${TABLE}."ISBN" ;;
  }

  dimension: core_text_isbn {
    type: string
    sql: ${TABLE}."CORE_TEXT_ISBN" ;;
  }

  dimension: org_id {
    type: number
    sql: ${TABLE}."ORG_ID" ;;
  }

  dimension: course_key {
    type: string
    sql: ${TABLE}."COURSE_KEY" ;;
  }

  dimension: branding_discipline {
    type: string
    sql: ${TABLE}."BRANDING_DISCIPLINE" ;;
  }

  dimension: gcs_status {
    type: string
    sql: ${TABLE}."GCS_STATUS" ;;
  }

  dimension: course_creation_type {
    type: string
    sql: ${TABLE}."COURSE_CREATION_TYPE" ;;
  }

  dimension: instructor_first_name {
    type: string
    sql: ${TABLE}."INSTRUCTOR_FIRST_NAME" ;;
  }

  dimension: instructor_last_name {
    type: string
    sql: ${TABLE}."INSTRUCTOR_LAST_NAME" ;;
  }

  dimension: instructor_email {
    type: string
    sql: ${TABLE}."INSTRUCTOR_EMAIL" ;;
  }

  dimension: instructor_guid {
    type: string
    sql: ${TABLE}."INSTRUCTOR_GUID" ;;
  }

  dimension: created_at {
    type: date
    sql: ${TABLE}."CREATED_AT" ;;
  }

  measure: course_count {
    label: "Course count"
    type: count_distinct
    sql: ${course_key} ;;
  }

  set: detail {
    fields: [
      institution,
      snapshot_id,
      parent_id,
      source_id,
      isbn,
      core_text_isbn,
      org_id,
      course_key,
      branding_discipline,
      gcs_status,
      course_creation_type,
      instructor_first_name,
      instructor_last_name,
      instructor_email,
      instructor_guid,
      created_at
    ]
  }
}
