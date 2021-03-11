# # explore: account_link_creation_cohort {}

# view: account_link_creation_cohort {

#     derived_table: {
#       explore_source: session_analysis {
#         column: user_sso_guid { field: learner_profile.user_sso_guid }
#         filters: {
#           field: all_events.local_est_date
#           value: "after 2019/08/01"
#         }
#         filters: {
#           field: all_events.event_name
#           value: "Course-Link-Sign-In Account-Creation,Course-Link-Sign-Up Account-Creation"
#         }
#         filters: {
#           field: live_subscription_status.subscription_status
#           value: "Full Access"
#         }
#       }

#     }

#     dimension: user_sso_guid {
#       label: "Learner Profile User SSO GUID"
#       description: "Primary Guid, after mapping and merging from shadow guids"
#     }


# }
