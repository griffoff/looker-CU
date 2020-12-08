explore: Fall_Review_FY21  {}


view: Fall_Review_FY21 {
sql_table_name:  strategy.adoption_pivot_FY21_v1.fy21_summerfall_pivot ;;
dimension: adoption_key {}
dimension: course_cd {}

measure: fy20_total_units  {
  description: "total Unit turnover in FY20"
  type: sum
  sql: strategy.adoption_pivot_FY21_v1.fy21_summerfall_pivot.fy20_total_units ;;
}}
