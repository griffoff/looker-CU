view: late_activators {
  derived_table: {
    create_process: {
      sql_step:
      --create table to store messages
        CREATE TABLE IF NOT EXISTS ${SQL_TABLE_NAME} (
          _ldts TIMESTAMP
          ,user_sso_guid STRING
          ,course_key STRING
          ,activation_date TIMESTAMP_TZ
          ,subscription_end_date TIMESTAMP_TZ
          ,promo_code STRING
          ,msg_type INT
          ,lookup STRING
        )
      ;;
      sql_step:
        --create table to store user + promo_code mapping so that we don't assign the same one to multiple users, or multiple codes to the same user
        CREATE TABLE IF NOT EXISTS looker_scratch.late_activators_promo_codes
        AS
        SELECT
          NULL::STRING AS user_sso_guid
          ,HASH(RANDOM(1)) AS promo_code
        FROM ${learner_profile.SQL_TABLE_NAME}
        LIMIT 30000
        --FROM somewhere ---TBD
      ;;
      sql_step:
        --get all users who fit the 30 day late activation criteria and write them to the messages table
        INSERT INTO ${SQL_TABLE_NAME}
        SELECT
          current_timestamp()
          ,user_courses.user_sso_guid
          ,user_courses.olr_course_key AS course_key
          ,user_courses.activation_date
          ,learner_profile.subscription_end AS subscription_end_date
          ,NULL AS promo_code
          ,CASE
            WHEN DATEDIFF(DAY, activation_date::DATE, CURRENT_DATE()) BETWEEN 0 AND 2
            THEN 1 --first message, soon after activation
            WHEN DATEDIFF(DAY, CURRENT_DATE(), subscription_end_date::DATE) = 7
            THEN 2 --message 7 days before access is removed (subscription end date)
            WHEN CURRENT_DATE() = subscription_end_date::DATE
            THEN 3
            ELSE 1
            END AS msg_type
          ,HASH(user_courses.user_sso_guid, activation_date, course_key, msg_type) as lookup
        FROM ${user_courses.SQL_TABLE_NAME} user_courses
        INNER JOIN ${learner_profile.SQL_TABLE_NAME} learner_profile ON user_courses.user_sso_guid = learner_profile.user_sso_guid
        WHERE learner_profile.subscription_status = 'Full Access'
        AND user_courses.activation_date IS NOT NULL
        AND user_courses.activation_date >= DATEADD(DAY, -30, subscription_end_date)
        --exclude people who have already been picked up for a given message
        AND lookup NOT IN (SELECT lookup FROM ${SQL_TABLE_NAME})
        ;;
      sql_step:
       MERGE INTO ${SQL_TABLE_NAME} a
        USING (
            SELECT user_sso_guid, promo_code
            FROM (
                SELECT user_sso_guid, dense_rank() OVER (ORDER BY RANDOM(1)) as id
                FROM (
                  SELECT DISTINCT user_sso_guid
                  FROM ${SQL_TABLE_NAME}
                  WHERE promo_code IS NULL
                )
              ) unassigned_users
            INNER JOIN (
              SELECT DISTINCT promo_code, dense_rank() OVER (ORDER BY RANDOM(1)) as id
              FROM looker_scratch.late_activators_promo_codes
              WHERE user_sso_guid IS NULL
                ) unassigned_promo_codes ON unassigned_users.id = unassigned_promo_codes.id
          ) p ON a.user_sso_guid = p.user_sso_guid
        WHEN MATCHED THEN UPDATE
          SET promo_code = p.promo_code
      ;;
      sql_step:
        INSERT INTO looker_scratch.late_activators_promo_codes
        SELECT DISTINCT user_sso_guid, promo_code
        FROM ${SQL_TABLE_NAME}
        WHERE user_sso_guid NOT IN (SELECT user_sso_guid FROM looker_scratch.late_activators_promo_codes)
      ;;
    }

    sql_trigger_value: CURRENT_DATE() ;;
  }

  dimension: user_sso_guid {}
  dimension: promo_code {}
  dimension: course_key {}
  dimension: activation_date {type:date}
  dimension: subscription_end_date {type:date}
  dimension: msg_type{ type:number}
  dimension: lookup {primary_key: yes hidden:yes}

}
