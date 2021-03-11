# view: user_institution_map {
#   derived_table: {


#     persist_for: "24 hours"

#     create_process: {
#       sql_step:
#         USE SCHEMA looker_scratch
#       ;;
#       # create a mapping of course key to entity no
#       sql_step:
#         create temporary table if not exists courses
#         as
#         select
#           course_key, coalesce(entity_no::string, entity_id_sub) as entity_no, entity_name_course
#         from prod.stg_clts.olr_courses
#         ;;

#       # add context ids (not all feeds are course key, some are context id)
#       sql_step:
#         insert into courses
#         select
#           "#CONTEXT_ID", coalesce(entity_no::string, entity_id_sub), entity_name_course
#         from prod.stg_clts.olr_courses
#         where "#CONTEXT_ID" not in (select course_key from courses)
#         ;;

#       # find entity no for courses where no id was found, by matching on name
#       sql_step:
#         merge into courses c
#         using (
#           select upper(institution_nm) as institution_nm, any_value(entity_no) as entity_no
#           from prod.stg_clts.entities
#           where entity_no is not null
#           group by 1
#         ) e on upper(c.entity_name_course) = e.institution_nm
#         and c.entity_no is null
#         when matched then
#         update
#         set entity_no = e.entity_no
#         ;;

#       sql_step:
#         delete from courses where entity_no = '-1';;

#       sql_step:
#         create table if not exists user_institution
#         (
#           RSRC string
#           ,user_sso_guid string primary key
#           ,course_key_count int
#           ,institution_count int
#           ,course_keys variant
#           ,entities variant
#           ,entity_no string
#         )
#         ;;

#       # identify coursekeys from user session data
#       # then from enrollments and activations
#       sql_step:
#         merge into user_institution ui
#         using (
#           select
#             'SESSIONS'::string as RSRC
#             ,user_sso_guid
#             ,count(distinct c.course_key) as course_key_count
#             ,count(distinct c.entity_no) as institution_count
#             ,array_agg(distinct c.course_key) as course_keys
#             ,array_agg(distinct c.entity_no) as entities
#             ,case when institution_count = 1 then any_value(c.entity_no) end as entity_no
#           from ${all_sessions.SQL_TABLE_NAME} s
#           cross join lateral flatten (s.course_keys, outer=>True) k
#           left join courses c on k.value::string = c.course_key
#           where user_sso_guid in (select user_sso_guid from user_institution where entity_no is null)
#           or user_sso_guid not in (select user_sso_guid from user_institution)
#           group by user_sso_guid
#         ) i on ui.user_sso_guid = i.user_sso_guid
#         when matched and ui.entity_no is null then
#         update
#           set institution_count = i.institution_count
#           ,entity_no = i.entity_no
#           ,RSRC = i.RSRC
#         when not matched then
#         insert (RSRC, user_sso_guid, course_key_count, institution_count, course_keys, entities, entity_no)
#         values (i.RSRC, i.user_sso_guid, i.course_key_count, i.institution_count, i.course_keys, i.entities, i.entity_no)
#         ;;

#       sql_step:
#         merge into user_institution ui
#         using (
#           select
#             'ENROLLMENTS' as RSRC
#             ,user_sso_guid
#             ,count(distinct c.course_key) as course_key_count
#             ,count(distinct c.entity_no) as institution_count
#             ,array_agg(distinct c.course_key) as course_keys
#             ,array_agg(distinct c.entity_no) as entities
#             ,case when institution_count = 1 then any_value(c.entity_no) end as entity_no
#           from olr.prod.raw_enrollment r
#           left join courses c on r.course_key = c.course_key
#           group by user_sso_guid
#         ) i on ui.user_sso_guid = i.user_sso_guid
#         when matched and ui.entity_no is null then
#         update
#           set institution_count = i.institution_count
#           ,entity_no = i.entity_no
#           ,RSRC = i.RSRC
#         when not matched then
#         insert (RSRC, user_sso_guid, course_key_count, institution_count, course_keys, entities, entity_no)
#         values (i.RSRC, i.user_sso_guid, i.course_key_count, i.institution_count, i.course_keys, i.entities, i.entity_no)
#         ;;

#       sql_step:
#         merge into looker_scratch.user_institution ui
#         using (
#           select
#             'ACTIVATIONS' as RSRC
#             ,user_guid as user_sso_guid
#             ,count(distinct c.course_key) as course_key_count
#             ,count(distinct c.entity_no) as institution_count
#             ,array_agg(distinct c.course_key) as course_keys
#             ,array_agg(distinct c.entity_no) as entities
#             ,case when institution_count = 1 then any_value(c.entity_no) end as entity_no
#           from prod.stg_clts.activations_olr r
#           left join courses c on r.CONTEXT_ID = c.course_key
#           where user_guid in (select user_sso_guid from user_institution where entity_no is null)
#           group by user_guid
#         ) i on ui.user_sso_guid = i.user_sso_guid
#         when matched and ui.entity_no is null then
#         update
#         set institution_count = i.institution_count
#         ,entity_no = i.entity_no
#         ,RSRC = i.RSRC
#         ;;

#         sql_step:
#           merge into user_institution ui
#           using (
#             select
#               'ACTIVATIONS - RAW' as RSRC
#               ,user_guid as user_sso_guid
#               ,count(distinct r.CONTEXT_ID) as course_key_count
#               ,count(distinct r.ACTV_ENTITY_ID) as institution_count
#               ,array_agg(distinct r.CONTEXT_ID) as course_keys
#               ,array_agg(distinct r.ACTV_ENTITY_ID) as entities
#               ,case when institution_count = 1 then any_value(r.ACTV_ENTITY_ID) end as entity_no
#             from prod.stg_clts.activations_olr r
#             where user_guid in (select user_sso_guid from user_institution where entity_no is null)
#             group by user_guid
#           ) i on ui.user_sso_guid = i.user_sso_guid
#           when matched and ui.entity_no is null then
#           update
#           set institution_count = i.institution_count
#           ,entity_no = i.entity_no
#           ,RSRC = i.RSRC
#           ;;

#         sql_step:
#           merge into user_institution ui
#           using (
#             select
#                 'USER_COURSES'::string as RSRC
#                 ,user_sso_guid
#                 ,count(distinct c.course_key) as course_key_count
#                 ,count(distinct c.entity_no) as institution_count
#                 ,array_agg(distinct c.course_key) as course_keys
#                 ,array_agg(distinct c.entity_no) as entities
#                 ,case when institution_count = 1 then any_value(c.entity_no) end as entity_no
#             from ${user_courses.SQL_TABLE_NAME} uc
#             inner join courses c on uc.olr_course_key = c.course_key
#             where user_sso_guid in (select user_sso_guid from user_institution where entity_no is null)
#             or user_sso_guid not in (select user_sso_guid from user_institution)
#             group by user_sso_guid
#           ) i on ui.user_sso_guid = i.user_sso_guid
#           when matched and ui.entity_no is null then
#           update
#             set institution_count = i.institution_count
#             ,entity_no = i.entity_no
#             ,RSRC = i.RSRC
#           when not matched then
#           insert (RSRC, user_sso_guid, course_key_count, institution_count, course_keys, entities, entity_no)
#           values (i.RSRC, i.user_sso_guid, i.course_key_count, i.institution_count, i.course_keys, i.entities, i.entity_no)
#           ;;

#         sql_step:
#           create or replace table ${SQL_TABLE_NAME} clone user_institution;;
#     }


#   }

#   dimension: RSRC {
#     label: "RSRC"
#     description: "Source table of record"
#   }
#   dimension: user_sso_guid {
#     label: "User SSO GUID"
#   }
#   dimension: entity_no {
#     label: "Entity number"
#     description: "A unique identifier for academic institutions"
#   }
# }
