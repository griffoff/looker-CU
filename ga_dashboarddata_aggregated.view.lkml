view: ga_dashboarddata_aggregated  {
  derived_table: {
    sql:
    SELECT
        userssoguid
        ,COUNT(CASE when eventaction like 'Calls To Action (CTAs)' and eventlabel like 'Add To My Content Position%' THEN 1 ELSE 0 END) AS add_to_my_content_position_count
        ,COUNT(CASE WHEN eventaction like 'Search Term%'  THEN 1 ELSE 0 END) AS searched_items_with_results_count
        ,COUNT(CASE WHEN eventaction like 'Calls To Action (CTAs)' and LOWER(eventlabel) like 'dashboard%ebook%'  THEN 1 ELSE 0 END) AS ebook_launched_count
        ,COUNT(CASE WHEN eventaction like 'Dashboard Course Launched Name%'  THEN 1 ELSE 0 END) AS courseware_launched_count
        ,COUNT(CASE WHEN eventaction like 'Explore Catalog%'  THEN 1 ELSE 0 END) AS catalog_explored_count
        ,COUNT(CASE WHEN eventaction LIKE 'Rent From Chegg%' OR eventaction like 'Exclusive Partner Clicked'  THEN 1 ELSE 0 END) AS Clicked_on_Chegg_count
        ,COUNT(CASE WHEN eventaction LIKE 'Search Bar No%'  THEN 1 ELSE 0 END) AS no_results_search_count
        ,COUNT(CASE WHEN eventaction LIKE 'Support Clicked'   THEN 1 ELSE 0 END) AS support_clicked_count
        ,COUNT(CASE WHEN eventaction LIKE '%FAQ%'  THEN 1 ELSE 0 END) AS faq_clicked_count
        ,COUNT(CASE WHEN eventaction like 'Calls To Action (CTAs)' and eventlabel like 'Buy Now Button Click'  THEN 1 ELSE 0 END) AS clicked_on_upgrade_count
    FROM prod.raw_ga.ga_dashboarddata
    GROUP BY 1


    ;;
 }

dimension: userssoguid {
  type:  string
}

dimension: add_to_my_content_position_count {
  group_label:"Action Counts"}

dimension: searched_items_with_results_count {
  group_label:"Action Counts"
}

dimension: ebook_launched_count {
  group_label:"Action Counts"
}

dimension: courseware_launched_count {
  group_label:"Action Counts"
}

dimension: catalog_explored_count {
  group_label:"Action Counts"
}

dimension: Clicked_on_Chegg_count {
  group_label:"Action Counts"
}

dimension: no_results_search_count {
  group_label:"Action Counts"
}

dimension: support_clicked_count {
  group_label:"Action Counts"
}

dimension: faq_clicked_count {
  group_label:"Action Counts"
}

dimension: clicked_on_upgrade_count {
  group_label:"Action Counts"
}


####


dimension: add_to_my_content_position_buckets {
  type:  tier
  tiers: [2, 4, 6, 8]
  style:  integer
  sql:  ${add_to_my_content_position_count} ;;
  group_label:"Action Buckets"
}

dimension: searched_items_with_results_buckets {
  type:  tier
  tiers: [2, 4, 6, 8]
  style:  integer
  sql:  ${searched_items_with_results_count} ;;
  group_label:"Action Buckets"
}

dimension: ebook_launched_buckets {
  type:  tier
  tiers: [2, 4, 6, 8]
  style:  integer
  sql:  ${ebook_launched_count} ;;
  group_label:"Action Buckets"
}

dimension: courseware_launched_buckets {
  type:  tier
  tiers: [2, 4, 6, 8]
  style:  integer
  sql:  ${courseware_launched_count} ;;
  group_label:"Action Buckets"
}

dimension: catalog_explored_buckets {
  type:  tier
  tiers: [2, 4, 6, 8]
  style:  integer
  sql:  ${catalog_explored_count} ;;
  group_label:"Action Buckets"
}

dimension: Clicked_on_Chegg_buckets {
  type:  tier
  tiers: [2, 4, 6, 8]
  style:  integer
  sql:  ${Clicked_on_Chegg_count} ;;
  group_label:"Action Buckets"
}


dimension: no_results_search_buckets {
  type:  tier
  tiers: [2, 4, 6, 8]
  style:  integer
  sql:  ${no_results_search_count} ;;
  group_label:"Action Buckets"
}

dimension: support_clicked_buckets {
  type:  tier
  tiers: [2, 4, 6, 8]
  style:  integer
  sql:  ${support_clicked_count} ;;
  group_label:"Action Buckets"
}

dimension: faq_clicked_buckets {
  type:  tier
  tiers: [2, 4, 6, 8]
  style:  integer
  sql:  ${faq_clicked_count} ;;
  group_label:"Action Buckets"
}

dimension: clicked_on_upgrade_buckets {
  type:  tier
  tiers: [2, 4, 6, 8]
  style:  integer
  sql:  ${clicked_on_upgrade_count} ;;
  group_label:"Action Buckets"
}



measure: count_users {
  type:  count_distinct
  sql: ${userssoguid} ;;

}
}



#               when ${eventcategory} like 'Course Key Registration' then 'Course Key Registration'
#               when ${eventcategory} like 'Access Code Registration' then 'Access Code Registration'
#               when ${eventcategory} like 'Videos' and eventaction like 'Meet Cengage Unlimited' then 'CU videos viewed'
#               ELSE 'Other' END
