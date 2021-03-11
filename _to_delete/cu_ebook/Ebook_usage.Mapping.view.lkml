# view: ebook_mapping {
#   derived_table: {
#     sql: Select * from uploads.EBOOK_USAGE.EBOOK_MAPPING where not _fivetran_deleted ;;
#   }


#   dimension: source {
#     type: string
#     label: "Reader Source Abbreviation"
#     description: "Which reader the event came from: MindTap Reader (MTR), MindTap Mobile Reader (MTM), or VitalSource Reader (VS)"
#     sql: ${TABLE}."SOURCE" ;;
#   }

#   dimension: common_action {
#     type: string
#     sql: ${TABLE}."MAP" ;;
#     label: "Reader Event"
#     description: "Reader events as defined in the reader documentation on the wike at: /display/cap/eBook+Reader+Events"
#   }

#   dimension: action {
#     type: string
#     sql: ${TABLE}."ACTION" ;;
#     label: "E-Book Reader specific action"
#     description: "An action specific to the given e-book reader platform"
#   }

#   dimension: event_category {
#     type: string
#     sql: ${TABLE}."CATEGORY" ;;
#     description: "A category of e-book actions specific to the given e-book reader platform"
#   }

#   measure: count {
#     type: count
#     drill_fields: []
#   }
# }
