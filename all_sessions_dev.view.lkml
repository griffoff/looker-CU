include: "all_sessions.view"


view: all_sessions_dev {
  extends: [all_sessions]
  label: "all sessions dev"
  sql_table_name: zpg.all_sessions ;;

}
