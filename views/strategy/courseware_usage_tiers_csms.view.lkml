# explore: courseware_usage_tiers_csms {}

view: courseware_usage_tiers_csms {
    derived_table: {
      sql:
      WITH MT_assignments_staging AS (
SELECT
"#CONTEXT_ID" AS CONTEXT_ID,
COUNT(DISTINCT CONCAT(OUTCOME.ID, OUTCOME.USERID)) AS CW_ACTIVITIES,
COUNT(DISTINCT OUTCOME.USERID) AS CW_USERS,
'MindTap' AS PLATFORM
FROM "PROD"."DW_GA"."FACT_ACTIVITYOUTCOME" OUTCOME
JOIN "PROD"."DW_GA"."DIM_ACTIVITY" ACTIVITY
    ON ACTIVITY.ACTIVITYID = OUTCOME.ACTIVITYID
JOIN "PROD"."DW_GA"."DIM_ACTIVITY_V" ACTVIEW
    ON ACTVIEW.ACTIVITYID = ACTIVITY.ACTIVITYID
    AND ACTIVITY.ASSIGNED = 1
JOIN "PROD"."DW_GA"."DIM_COURSE" COURSE
    ON OUTCOME.COURSEID = COURSE.COURSEID
JOIN "PROD"."DW_GA"."DIM_USER_V" USER
    ON OUTCOME.USERID = USER.USERID
    AND USER.USERROLE = 'STUDENT'
JOIN "PROD"."STG_CLTS"."OLR_COURSES" OLR
    ON COURSE.COURSEKEY = OLR.COURSE_KEY
JOIN "STRATEGY"."DW"."DM_COURSE_ENROLLMENTS" ENROLL
    ON OLR."#CONTEXT_ID" = ENROLL.CONTEXT_ID
WHERE
    OUTCOME.COMPLETED = 'True'
AND COURSE_BEGIN_DATE >= '2018-04-01'
AND OUTCOME.SCORE > 0
GROUP BY
"#CONTEXT_ID"
),


--WebAssign Activities
WA_ACTIVITIES AS (
select assignment.assignment_id
,responses.user_id
,section_id
,context_id
,course_key
,users.sso_guid
,array_to_string(array_slice(wa_match.guids, 0, 1),'') as email_guid --take first instance (as is decscending date ordered) of guid assocaited from email from pete's match to the user mutation table
,coalesce(sso_guid, email_guid) as coal_guid  --first take sso_guid listed in webassign users table, then take guid associated with email from Pete's match to IAM.user_mutation table
,COALESCE(guids.primary_guid, coal_guid) AS merged_guid --get best guid from user table then email table then check for merged_guid
,online_product_isbn13 as isbn13
,to_date(date_trunc('DAY',max(logged))) as submit_day
FROM "PROD"."WEBASSIGN"."RESPONSES" responses
LEFT JOIN "WEBASSIGN"."FT_OLAP_REGISTRATION_REPORTS"."DIM_DEPLOYMENT" deployment
    ON responses.deployment_id = deployment.deployment_id
LEFT JOIN "WEBASSIGN"."FT_OLAP_REGISTRATION_REPORTS"."DIM_ASSIGNMENT" assignment
    ON deployment.dim_assignment_id = assignment.dim_assignment_id
LEFT JOIN "STRATEGY"."DW"."DM_COURSE_ENROLLMENTS" enroll
   ON to_char(deployment.section_id)= to_char(enroll.context_id) --be sure to look up to context_id instead of course_key; in cases where course_key and context_id are mismatched, it properly looks up to context_id
LEFT JOIN "WEBASSIGN"."WA_APP_V4NET"."USERS" users
    ON responses.user_id = users.id
LEFT JOIN "STRATEGY"."GRADED_ANALYSIS"."WA_MATCH"
    ON users.email = wa_match.email
LEFT JOIN "PROD"."UNLIMITED"."VW_PARTNER_TO_PRIMARY_USER_GUID" guids
    ON  COALESCE(users.sso_guid, array_to_string(array_slice(wa_match.guids, 0, 1),'')) = guids.partner_guid --get best guid from user table then email table then check for merged_guid
LEFT JOIN prod.stg_clts.products product
    ON to_char(enroll.online_product_isbn13) = product.isbn13
WHERE
    logged > '01-Apr-2018' --not much good earlier data
AND assignment.trashed = 'n' and deployment.psp = 'N' --get rid of deleted and personalized study plan activities
AND (
upper(category) LIKE '%HOMEWORK%' OR
upper(category) LIKE '%QUIZ%' OR
upper(category) LIKE '%HW%' OR
upper(category) LIKE '%GRADED%' OR
upper(category) LIKE 'LAB%' OR  -->only at start, otherwise get pre-lab, post-lab, in-lab
upper(category) LIKE '%REQUIRED%' OR
upper(category) LIKE '%TEST%' OR
upper(category) LIKE '%EXAM%'
)
AND(
upper(category) NOT LIKE '%PRACTICE%' AND
upper(category) NOT LIKE '%UNGRADED%' AND
upper(category) NOT LIKE '%NOT GRADED%'
)
group by 1,2,3,4,5,6,7,8,9,10
),


--Cleanups up WA activities
--CREATE OR REPLACE TEMPORARY TABLE
WA_assignments_staging AS (
SELECT
CONTEXT_ID,
COUNT(DISTINCT CONCAT(ASSIGNMENT_ID, USER_ID)) AS CW_ACTIVITIES,
COUNT(DISTINCT USER_ID) AS CW_USERS,
'WebAssign' AS PLATFORM
FROM WA_ACTIVITIES
GROUP BY
CONTEXT_ID
ORDER BY
CONTEXT_ID DESC
),


--Consolidates all CW Activities, Users, and Platforms
MTandWA_CW_Activities AS (
SELECT * FROM MT_assignments_staging
UNION ALL
SELECT * FROM WA_assignments_staging
),


--OLR Activations
TEMP_ACTIVITATIONS AS (
SELECT
CONTEXT_ID,
PLATFORM,
SUM(ACTV_COUNT) ACTV_COUNT
FROM "PROD"."STG_CLTS"."ACTIVATIONS_OLR" OLR
JOIN "STRATEGY"."DW"."DM_DATE_DIMENSION" DATEDIM
    ON OLR.ACTV_DT = DATEDIM.CALENDAR_DATE
WHERE
    FISCAL_YEAR >= 2019
AND ORGANIZATION = 'Higher Ed'
AND ACTV_TRIAL_PURCHASE IN ('Site License', 'Purchase')
AND PLATFORM IN ('MindTap', 'WebAssign')
AND CONTEXT_ID IS NOT NULL
AND IN_ACTV_FLG = 1
GROUP BY
CONTEXT_ID,
PLATFORM
ORDER BY
CONTEXT_ID
),


--Adding in all relevant instructor level data
--CREATE OR REPLACE TEMPORARY TABLE
CW_Usage_Tiers_Staging AS (
SELECT
DATEDIM.CALENDAR_YEAR AS "CALENDAR YEAR",
CASE WHEN DATEDIM.CALENDAR_MONTHOFYEAR BETWEEN 1 AND 4 THEN 'Spring'
     WHEN DATEDIM.CALENDAR_MONTHOFYEAR BETWEEN 5 AND 7 THEN 'Summer'
     WHEN DATEDIM.CALENDAR_MONTHOFYEAR BETWEEN 8 AND 12 THEN 'Fall'
     ELSE NULL END SEMESTER,
ENT.STATE_DE AS STATE,
ENT.INSTITUTION_NM AS INSTITUTION,
ENT.ENTITY_NO AS ENTITY,
CONCAT(LDAP_INSTR_FIRST_NAME, ' ', LDAP_INSTR_LAST_NAME) AS "INSTRUCTOR NAME",
CASE WHEN FAM.COURSE_DE IS NULL THEN 'N/A' ELSE COURSE_DE END COURSE,
PROD.PUB_SERIES_DE AS DISCIPLINE,
PROD.PUBL_GRP_DE AS SPECIALIZATION,
MAP.CATEGORY,
ACTV.PLATFORM,
SUM(ACTV.ACTV_COUNT) AS ACTIVATIONS,
SUM(CWUSAGE.CW_ACTIVITIES) AS CW_ACTIVITIES,
SUM(CWUSAGE.CW_USERS) AS CW_USERS,
ROUND(SUM(CWUSAGE.CW_ACTIVITIES)/SUM(CWUSAGE.CW_USERS),1) AS CW_ACTIVITIES_PER_USER
FROM TEMP_ACTIVITATIONS ACTV
LEFT JOIN MTandWA_CW_Activities CWUSAGE
    ON ACTV.CONTEXT_ID = CWUSAGE.CONTEXT_ID
JOIN "STRATEGY"."DW"."DM_COURSE_ENROLLMENTS" COURSE
    ON ACTV.CONTEXT_ID = COURSE.CONTEXT_ID
JOIN "STRATEGY"."DW"."DM_DATE_DIMENSION" DATEDIM
    ON COURSE.COURSE_BEGIN_DATE = DATEDIM.CALENDAR_DATE
LEFT JOIN "PROD"."STG_CLTS"."PRODUCTS" PROD
    ON PROD.ISBN13 = COURSE.ONLINE_PRODUCT_ISBN13
LEFT JOIN "STRATEGY"."DW"."DM_PRODUCT_FAMILY_MASTER" FAM
    ON PROD.PROD_FAMILY_CD = FAM.PROD_FAMILY_CD
LEFT JOIN "STRATEGY"."RMCDONOUGH"."DISCIPLINE_CATEGORY_MAPPING" MAP
    ON MAP.DISCIPLINE = PROD.PUB_SERIES_DE
JOIN "STRATEGY"."DW"."DM_ENTITIES" ENT
    ON COURSE.ENTITY_NO = ENT.ENTITY_NO
GROUP BY
"CALENDAR_YEAR",
SEMESTER,
STATE,
INSTITUTION,
ENTITY,
"INSTRUCTOR NAME",
FAM.COURSE_DE,
CATEGORY,
PROD.PUB_SERIES_DE,
PROD.PUBL_GRP_DE,
ACTV.PLATFORM
ORDER BY
CALENDAR_YEAR,
SEMESTER
),


--Removes NULL values and replaces them with zeros
CW_Usage_Tiers_Staging_WITHOUTNULLS AS (
SELECT
"CALENDAR YEAR",
SEMESTER,
STATE,
INSTITUTION,
ENTITY,
"INSTRUCTOR NAME",
COURSE,
DISCIPLINE,
SPECIALIZATION,
CATEGORY,
PLATFORM,
ACTIVATIONS,
CASE WHEN CW_ACTIVITIES IS NULL THEN 0 ELSE CW_ACTIVITIES END CW_ACTIVITIES,
CASE WHEN CW_USERS IS NULL THEN 0 ELSE CW_USERS END CW_USERS,
CASE WHEN CW_ACTIVITIES_PER_USER IS NULL THEN 0 ELSE CW_ACTIVITIES_PER_USER END CW_ACTIVITIES_PER_USER
FROM CW_Usage_Tiers_Staging
),



--Highlights the minimum year with
FIRST_YEAR_WITH_CENGAGE_INSTRUCTOR AS (
SELECT
MIN("CALENDAR YEAR") AS "FIRST YEAR WITH CENGAGE",
"INSTRUCTOR NAME",
INSTITUTION
FROM CW_Usage_Tiers_Staging_WITHOUTNULLS nonulls
GROUP BY
"INSTRUCTOR NAME",
INSTITUTION
ORDER BY
"FIRST YEAR WITH CENGAGE"
)
,



--First year the instructor has activated a digital Cengage product
FIRST_YEAR_WITH_CENGAGE_COURSE AS (
SELECT
MIN("CALENDAR YEAR") AS "FIRST YEAR WITH COURSE",
"INSTRUCTOR NAME",
INSTITUTION,
COURSE
FROM CW_Usage_Tiers_Staging_WITHOUTNULLS nonulls
GROUP BY
"INSTRUCTOR NAME",
INSTITUTION,
COURSE
ORDER BY
"FIRST YEAR WITH COURSE"
),


--Usage Tiers put into the appropriate Quartiles
CW_USAGE_TIERS_THREENTILES AS (
SELECT
*,
CASE WHEN (NTILE(3) OVER (PARTITION BY "CALENDAR YEAR", SEMESTER, DISCIPLINE ORDER BY (CW_ACTIVITIES_PER_USER) DESC) = 1) THEN '1: High'
     WHEN (NTILE(3) OVER (PARTITION BY "CALENDAR YEAR", SEMESTER, DISCIPLINE ORDER BY (CW_ACTIVITIES_PER_USER) DESC) = 2) THEN '2: Medium'
     WHEN (NTILE(3) OVER (PARTITION BY "CALENDAR YEAR", SEMESTER, DISCIPLINE ORDER BY (CW_ACTIVITIES_PER_USER) DESC) = 3) THEN '3: Low'
ELSE NULL END
DISCIPLINE_USAGE_TIER
FROM CW_Usage_Tiers_Staging_WITHOUTNULLS
ORDER BY
"CALENDAR YEAR" DESC,
SEMESTER,
DISCIPLINE,
DISCIPLINE_USAGE_TIER,
CW_ACTIVITIES_PER_USER DESC
),


--High Usage Tier Minimum calculated by discipline
CW_USAGE_TIERS_MINIMUM_HIGH AS (
SELECT
"CALENDAR YEAR",
SEMESTER,
DISCIPLINE,
DISCIPLINE_USAGE_TIER,
MIN(CW_ACTIVITIES_PER_USER) AS TIER_MINIMUM
FROM CW_USAGE_TIERS_THREENTILES
WHERE
DISCIPLINE_USAGE_TIER = '1: High'
GROUP BY
"CALENDAR YEAR",
SEMESTER,
DISCIPLINE,
DISCIPLINE_USAGE_TIER
ORDER BY
"CALENDAR YEAR" DESC,
SEMESTER,
DISCIPLINE,
DISCIPLINE_USAGE_TIER
),


--Medium Usage Tier Minimum calculated by discipline
CW_USAGE_TIERS_MINIMUM_MEDIUM AS (
SELECT
"CALENDAR YEAR",
SEMESTER,
DISCIPLINE,
DISCIPLINE_USAGE_TIER,
MIN(CW_ACTIVITIES_PER_USER) AS TIER_MINIMUM
FROM CW_USAGE_TIERS_THREENTILES
WHERE
DISCIPLINE_USAGE_TIER = '2: Medium'
GROUP BY
"CALENDAR YEAR",
SEMESTER,
DISCIPLINE,
DISCIPLINE_USAGE_TIER
ORDER BY
"CALENDAR YEAR" DESC,
SEMESTER,
DISCIPLINE,
DISCIPLINE_USAGE_TIER
),


--Low Usage Tier Minimum calculated by discipline
CW_USAGE_TIERS_MINIMUM_LOW AS (
SELECT
"CALENDAR YEAR",
SEMESTER,
DISCIPLINE,
DISCIPLINE_USAGE_TIER,
MIN(CW_ACTIVITIES_PER_USER) AS TIER_MINIMUM
FROM CW_USAGE_TIERS_THREENTILES
WHERE
DISCIPLINE_USAGE_TIER = '3: Low'
GROUP BY
"CALENDAR YEAR",
SEMESTER,
DISCIPLINE,
DISCIPLINE_USAGE_TIER
ORDER BY
"CALENDAR YEAR" DESC,
SEMESTER,
DISCIPLINE,
DISCIPLINE_USAGE_TIER
),


--Final Output Table
--CREATE OR REPLACE TABLE "STRATEGY"."RMCDONOUGH"."CW_USAGE_CSM_DASHBOARD" AS
CW_USAGE_CSM_DASHBOARD AS (
SELECT
STAG."CALENDAR YEAR",
STAG.SEMESTER,
STATE,
STAG.INSTITUTION,
STAG.ENTITY,
AE_DISTRICT_MANAGER,
AE_FY_21_TERRITORY AS AE_TERRITORY,
PSLC_DISTRICT_MANAGER,
PSLC_FY_21_TERRITORY AS PSLC_TERRITORY,
STAG."INSTRUCTOR NAME",
STAG.COURSE,
STAG.DISCIPLINE,
SPECIALIZATION,
CATEGORY,
PLATFORM,
CASE WHEN FIRST_YEAR."INSTRUCTOR NAME" IS NOT NULL THEN 'Yes' ELSE 'No' END "FIRST YEAR WITH CENGAGE",
CASE WHEN FIRST_COURSE."INSTRUCTOR NAME" IS NOT NULL THEN 'Yes' ELSE 'No' END "FIRST YEAR WITH COURSE",
ACTIVATIONS,
CASE WHEN CW_ACTIVITIES_PER_USER < MIN_MEDIUM.TIER_MINIMUM THEN 'At Risk' ELSE 'Healthy' END "USAGE HEALTH",
ROUND(CW_ACTIVITIES_PER_USER,0) AS CW_ACTIVITIES_PER_USER,
ROUND(MIN_LOW.TIER_MINIMUM,0) AS LOW_USAGE_THRESHOLD,
ROUND(MIN_MEDIUM.TIER_MINIMUM,0) AS MEDIUM_USAGE_THRESHOLD,
ROUND(MIN_HIGH.TIER_MINIMUM,0) AS HIGH_USAGE_THRESHOLD
FROM CW_Usage_Tiers_Staging_WITHOUTNULLS STAG
LEFT JOIN CW_USAGE_TIERS_MINIMUM_HIGH MIN_HIGH
    ON STAG."CALENDAR YEAR" = MIN_HIGH."CALENDAR YEAR"
    AND STAG.SEMESTER = MIN_HIGH.SEMESTER
    AND STAG.DISCIPLINE = MIN_HIGH.DISCIPLINE
LEFT JOIN CW_USAGE_TIERS_MINIMUM_MEDIUM MIN_MEDIUM
    ON STAG."CALENDAR YEAR" = MIN_MEDIUM."CALENDAR YEAR"
    AND STAG.SEMESTER = MIN_MEDIUM.SEMESTER
    AND STAG.DISCIPLINE = MIN_MEDIUM.DISCIPLINE
LEFT JOIN CW_USAGE_TIERS_MINIMUM_LOW MIN_LOW
    ON STAG."CALENDAR YEAR" = MIN_LOW."CALENDAR YEAR"
    AND STAG.SEMESTER = MIN_LOW.SEMESTER
    AND STAG.DISCIPLINE = MIN_LOW.DISCIPLINE
LEFT JOIN "STRATEGY"."RMCDONOUGH"."ENTITY_DM_FY21TERRITORY_MAPPING" AE
    ON STAG.ENTITY = AE.ENTITY
LEFT JOIN FIRST_YEAR_WITH_CENGAGE_INSTRUCTOR FIRST_YEAR
    ON STAG.INSTITUTION = FIRST_YEAR.INSTITUTION
    AND STAG."INSTRUCTOR NAME" = FIRST_YEAR."INSTRUCTOR NAME"
    AND STAG."CALENDAR YEAR" = FIRST_YEAR."FIRST YEAR WITH CENGAGE"
LEFT JOIN FIRST_YEAR_WITH_CENGAGE_COURSE FIRST_COURSE
    ON STAG.INSTITUTION = FIRST_COURSE.INSTITUTION
    AND STAG."INSTRUCTOR NAME" = FIRST_COURSE."INSTRUCTOR NAME"
    AND STAG."CALENDAR YEAR" = FIRST_COURSE."FIRST YEAR WITH COURSE"
    AND STAG.COURSE = FIRST_COURSE.COURSE
ORDER BY
"CALENDAR YEAR" DESC,
SEMESTER,
DISCIPLINE,
CW_ACTIVITIES_PER_USER DESC
)

SELECT * FROM CW_USAGE_CSM_DASHBOARD






      ;;

      sql_trigger_value: SELECT COUNT(*) FROM PROD.WEBASSIGN.RESPONSES ;;
  }

    measure: courseware_activities {
      type:  sum
      sql:  ${TABLE}.CW_ACTIVITIES_PER_USER
      ;;
  }

    dimension: calendar_year {
      type: number
      sql:  ${TABLE}."CALENDAR YEAR"
      ;;
  }

    dimension: semester {
      type: string
      sql:  ${TABLE}.SEMESTER
      ;;
    }

    dimension: state {
      type: string
      sql:  ${TABLE}.STATE
      ;;
  }

    dimension: institution {
      type:  string
      sql:  ${TABLE}.INSTITUTION
      ;;
  }

    dimension: entity {
      type:  number
      sql:  ${TABLE}.ENTITY
      ;;
  }

  dimension:  ae_district_manager {
    type: string
    sql:  ${TABLE}.ae_district_manager
      ;;
  }

  dimension:  ae_territory {
    type: string
    sql:  ${TABLE}.ae_territory
      ;;
  }

  dimension:  pslc_district_manager {
    type: string
    sql:  ${TABLE}.pslc_district_manager
      ;;
  }

  dimension:  pslc_territory {
    type: string
    sql:  ${TABLE}.pslc_territory
      ;;
  }

    dimension:  instructor_name {
      type: string
      sql:  ${TABLE}."INSTRUCTOR NAME"
      ;;
    }

    dimension: course {
      type: string
      sql:  ${TABLE}.COURSE
      ;;
    }

    dimension: discipline {
      type: string
      sql:  ${TABLE}.DISCIPLINE
      ;;
    }

    dimension: specialization {
      type: string
      sql:  ${TABLE}.SPECIALIZATION
      ;;
    }

    dimension: category {
      type: string
      sql:  ${TABLE}.CATEGORY
      ;;
    }

    dimension: platform {
      type: string
      sql: ${TABLE}.PLATFORM
      ;;
    }

  dimension: first_year_with_cengage {
    type: string
    sql: ${TABLE}."FIRST YEAR WITH CENGAGE"
      ;;
  }

  dimension: first_year_with_course {
    type: string
    sql: ${TABLE}."FIRST YEAR WITH COURSE"
      ;;
  }

  dimension: activations {
    type: number
    sql: ${TABLE}.activations
      ;;
  }

    dimension:  usage_health {
    type: string
    sql:  ${TABLE}."USAGE HEALTH"
      ;;
  }

    measure: medium_usage_threshold {
      type: sum
      sql:  ${TABLE}.MEDIUM_USAGE_THRESHOLD
      ;;
    }

    measure: high_usage_threshold {
      type: sum
      sql:  ${TABLE}.HIGH_USAGE_THRESHOLD
      ;;
  }



  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: courseware_usage_tiers_csms {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
