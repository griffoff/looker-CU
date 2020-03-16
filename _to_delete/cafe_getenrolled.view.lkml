include: "client_activity_event_prod.view"

explore: cafe_getenrolled {
  from: client_activity_event_prod
  sql_always_where: ${product_platform} = 'get-enrolled' ;;
}
