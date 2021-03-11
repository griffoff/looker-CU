# view: cu_ebook_usage_user_month {
# # If necessary, uncomment the line below to include explore_source.
# # include: "raw_datasets.model.lkml"

#     derived_table: {
#       explore_source: learner_profile_dev {
#         column: usage_count { field: cu_ebook_usage.count }
#         column: user_sso_guid { field: cu_ebook_usage.user_sso_guid }
#         column: activity_month { field: cu_ebook_usage.activity_month }
# #         filters: {
# #           field: cu_ebook_usage.count
# #           value: ">1"
# #         }
#       }
#     }
#     dimension: pk {
#       sql: hash(${user_sso_guid}, ${activity_month}) ;;
#       primary_key: yes
#       hidden: yes
#     }
#     dimension: used {
#       type: yesno
#       description: "A user is considered to have used ebook functionality in a given month if they have more than 1 occurence of ebook usage in that month"
#       sql: ${usage_count} > 1 ;;
#     }
#     dimension: usage_count {
#       type: number
#       description: "How many times a user used ebooks in a given month"
#       sql: coalesce(${TABLE}.usage_count, 0) ;;
#     }
#     dimension: usage_count_tier {
#       description: "How many times a user used ebooks in a given month"
#       type: tier
#       sql: ${usage_count};;
#       tiers: [1, 2]
#       style: integer
#     }
#     dimension: user_sso_guid {
#       hidden: yes
#     }
#     dimension: activity_month {
#       type: date_month
#       hidden: yes
#     }
#   }
