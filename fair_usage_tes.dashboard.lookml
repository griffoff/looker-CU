- dashboard: active_users_dau_wau_mau
  title: 'Active Users: DAU, WAU, MAU'
  layout: newspaper
  elements:
  - title: 'MT: Weekly Active Users'
    name: 'MT: Weekly Active Users'
    model: cube
    explore: LP_Siteusage_Analysis
    type: looker_column
    fields:
    - LP_Siteusage_Analysis.eventdate_week
    - LP_Siteusage_Analysis.usercount
    filters:
      dim_institution.HED_filter: 'Yes'
      dim_filter.is_external: 'Yes'
      dim_party.is_external: 'Yes'
      dim_institution.institutionname: ''
      LP_Siteusage_Analysis.eventdate_date: 13 months
      LP_Siteusage_Analysis.eventdate_week: after 2018/08/01
    sorts:
    - LP_Siteusage_Analysis.eventdate_week
    limit: 1000
    column_limit: 50
    total: true
    row_total: right
    query_timezone: America/Los_Angeles
    stacking: normal
    show_value_labels: false
    label_density: 25
    legend_position: right
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    limit_displayed_rows: true
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: ordinal
    y_axis_scale_mode: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: true
    show_silhouette: true
    totals_color: "#006298"
    show_null_points: true
    point_style: none
    interpolation: linear
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    series_types: {}
    hidden_series: []
    hidden_fields:
    swap_axes: false
    y_axis_reversed: false
    x_axis_label: Week Starting
    colors:
    - "#67AE3F"
    - "#e0004d"
    - "#0b689b"
    - "#ffc72c"
    series_colors:
      LP_Siteusage_Analysis.usercount: "#0b689b"
    font_size: ''
    y_axes:
    - label: Distinct Users
      maxValue:
      minValue:
      orientation: left
      showLabels: true
      showValues: false
      tickDensity: default
      tickDensityCustom: 5
      type: linear
      unpinAxis: false
      valueFormat:
      series:
      - id: LP_Siteusage_Analysis.usercount
        name: 'Learning Path - Usage Data # Users (Distinct)'
        axisId: LP_Siteusage_Analysis.usercount
    column_group_spacing_ratio: 0.1
    limit_displayed_rows_values:
      show_hide: hide
      first_last: last
      num_rows: '1'
    x_axis_datetime_label: ''
    column_spacing_ratio:
    hide_legend: false
    x_padding_right: 20
    listen: {}
    row: 29
    col: 0
    width: 12
    height: 7
  - title: 'MT: Monthly Active Users'
    name: 'MT: Monthly Active Users'
    model: cube
    explore: LP_Siteusage_Analysis
    type: looker_column
    fields:
    - LP_Siteusage_Analysis.eventdate_month
    - LP_Siteusage_Analysis.usercount
    fill_fields:
    - LP_Siteusage_Analysis.eventdate_month
    filters:
      dim_institution.HED_filter: 'Yes'
      dim_filter.is_external: 'Yes'
      dim_party.is_external: 'Yes'
      LP_Siteusage_Analysis.eventdate_date: after 2018/08/01
    sorts:
    - LP_Siteusage_Analysis.eventdate_month
    limit: 1000
    column_limit: 50
    query_timezone: America/Los_Angeles
    stacking: normal
    colors:
    - "#006298"
    - "#ffc72c"
    show_value_labels: false
    label_density: 25
    font_size: ''
    legend_position: center
    hide_legend: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    point_style: none
    series_colors: {}
    series_types: {}
    limit_displayed_rows: false
    limit_displayed_rows_values:
      show_hide: hide
      first_last: last
      num_rows: '1'
    hidden_series: []
    x_padding_right: 20
    y_axes:
    - label: Distinct Users
      maxValue:
      minValue:
      orientation: left
      showLabels: true
      showValues: true
      tickDensity: default
      tickDensityCustom: 5
      type: linear
      unpinAxis: false
      valueFormat:
      series:
      - id: LP_Siteusage_Analysis.usercount
        name: 'Learning Path - Usage Data # Users (Distinct)'
        axisId: LP_Siteusage_Analysis.usercount
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    x_axis_label: Month
    show_x_axis_ticks: true
    x_axis_datetime_label: "%b %Y"
    x_axis_scale: ordinal
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    ordering: none
    show_null_labels: false
    column_group_spacing_ratio: 0.1
    show_totals_labels: true
    show_silhouette: true
    totals_color: "#006298"
    show_null_points: true
    interpolation: linear
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_fields:
    swap_axes: false
    listen: {}
    row: 29
    col: 12
    width: 12
    height: 7
  - title: 'MT: Daily Active Users'
    name: 'MT: Daily Active Users'
    model: cube
    explore: LP_Siteusage_Analysis
    type: looker_column
    fields:
    - LP_Siteusage_Analysis.usercount
    - LP_Siteusage_Analysis.eventdate_date
    fill_fields:
    - LP_Siteusage_Analysis.eventdate_date
    filters:
      dim_institution.HED_filter: 'Yes'
      dim_filter.is_external: 'Yes'
      dim_party.is_external: 'Yes'
      LP_Siteusage_Analysis.eventdate_date: 31 days
    sorts:
    - LP_Siteusage_Analysis.eventdate_date
    limit: 1000
    column_limit: 50
    query_timezone: America/Los_Angeles
    stacking: normal
    colors:
    - "#006298"
    - "#ffc72c"
    show_value_labels: false
    label_density: 25
    font_size: ''
    legend_position: center
    hide_legend: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    point_style: none
    series_colors: {}
    series_types: {}
    limit_displayed_rows: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: last
      num_rows: '4'
    hidden_series: []
    x_padding_right: 20
    y_axes:
    - label: Distinct Users
      maxValue:
      minValue:
      orientation: left
      showLabels: true
      showValues: true
      tickDensity: default
      tickDensityCustom: 5
      type: linear
      unpinAxis: false
      valueFormat:
      series:
      - id: LP_Siteusage_Analysis.usercount
        name: 'Learning Path - Usage Data # Users (Distinct)'
        axisId: LP_Siteusage_Analysis.usercount
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    x_axis_label: Month
    show_x_axis_ticks: true
    x_axis_datetime_label: "%b %Y"
    x_axis_scale: ordinal
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    ordering: none
    show_null_labels: false
    column_group_spacing_ratio: 0.1
    show_totals_labels: true
    show_silhouette: true
    totals_color: "#006298"
    show_null_points: true
    interpolation: linear
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_fields:
    swap_axes: false
    listen: {}
    row: 22
    col: 0
    width: 24
    height: 7
  - title: 'CU Dashboard: Weekly Active User Intensity'
    name: 'CU Dashboard: Weekly Active User Intensity'
    model: fair_usage
    explore: raw_fair_use_logins
    type: looker_column
    fields:
    - raw_fair_use_logins.distinct_users
    - logins_last_7_days.distinct_days_used
    filters:
      raw_fair_use_logins.message_type: LoginEvent
      raw_fair_use_logins.platform_environment: production
      raw_fair_use_logins.product_platform: cares-dashboard
      raw_fair_use_logins.user_environment: production
      raw_fair_use_logins._ldts_date: 60 days
    sorts:
    - raw_fair_use_logins.distinct_users desc
    limit: 500
    total: true
    dynamic_fields:
    - table_calculation: of_total
      label: "% of total"
      expression: "${raw_fair_use_logins.distinct_users}/${raw_fair_use_logins.distinct_users:total}"
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      _type_hint: number
    query_timezone: America/Los_Angeles
    stacking: ''
    show_value_labels: true
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    point_style: none
    series_types: {}
    limit_displayed_rows: false
    limit_displayed_rows_values:
      show_hide: hide
      first_last: last
      num_rows: '1'
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    x_axis_label: Days Logged In (Previous 7)
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    ordering: none
    show_null_labels: false
    show_dropoff: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    hidden_fields:
    - raw_fair_use_logins.distinct_users
    listen: {}
    note_state: collapsed
    note_display: above
    note_text: Days (of last 7) a distinct user logged in
    row: 8
    col: 12
    width: 12
    height: 6
  - title: 'CU Dashboard: User Intensity (last 30 days)'
    name: 'CU Dashboard: User Intensity (last 30 days)'
    model: fair_usage
    explore: raw_fair_use_logins
    type: looker_column
    fields:
    - logins_last_30_days.distinct_days_used
    - raw_fair_use_logins.distinct_users
    filters:
      raw_fair_use_logins.message_type: LoginEvent
      raw_fair_use_logins.platform_environment: production
      raw_fair_use_logins.product_platform: cares-dashboard
      raw_fair_use_logins.user_environment: production
      raw_fair_use_logins._ldts_date: 60 days
    sorts:
    - raw_fair_use_logins.distinct_users desc
    limit: 500
    total: true
    dynamic_fields:
    - table_calculation: of_total
      label: "% of total"
      expression: "${raw_fair_use_logins.distinct_users}/${raw_fair_use_logins.distinct_users:total}"
      value_format:
      value_format_name: percent_2
      _kind_hint: measure
      _type_hint: number
    query_timezone: America/Los_Angeles
    stacking: ''
    show_value_labels: true
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    point_style: none
    series_types: {}
    limit_displayed_rows: false
    limit_displayed_rows_values:
      show_hide: hide
      first_last: last
      num_rows: '1'
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    x_axis_label: Days Logged In (Previous 30)
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    ordering: none
    show_null_labels: false
    show_dropoff: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    hidden_fields:
    - raw_fair_use_logins.distinct_users
    listen: {}
    note_state: collapsed
    note_display: above
    note_text: Days (of last 30) a distinct user logged in
    row: 14
    col: 12
    width: 12
    height: 6
  - name: Mindtap
    type: text
    title_text: Mindtap
    subtitle_text: Data Feed Delayed 1-2 days; HED only
    body_text: ''
    row: 20
    col: 0
    width: 24
    height: 2
  - name: CU Dashboard
    type: text
    title_text: CU Dashboard
    row: 0
    col: 0
    width: 24
    height: 2
  - name: CU Dashboard - DAU
    title: CU Dashboard - DAU
    model: fair_usage
    explore: raw_fair_use_logins
    type: looker_column
    fields:
    - raw_fair_use_logins.distinct_users
    - raw_fair_use_logins._ldts_date
    fill_fields:
    - raw_fair_use_logins._ldts_date
    filters:
      raw_fair_use_logins._ldts_month: 28 days
      raw_fair_use_logins.message_format_version: ''
      raw_fair_use_logins.message_type: LoginEvent
      raw_fair_use_logins.platform_environment: production
      raw_fair_use_logins.product_platform: cares-dashboard
      raw_fair_use_logins.user_environment: production
    sorts:
    - raw_fair_use_logins._ldts_date desc
    limit: 500
    query_timezone: America/Los_Angeles
    stacking: ''
    show_value_labels: true
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    point_style: none
    series_types: {}
    limit_displayed_rows: false
    limit_displayed_rows_values:
      show_hide: hide
      first_last: last
      num_rows: '1'
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    x_axis_label: Week
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    ordering: none
    show_null_labels: false
    show_dropoff: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    row: 2
    col: 0
    width: 24
    height: 6
  - name: CU Dashboard - MAU
    title: CU Dashboard - MAU
    model: fair_usage
    explore: raw_fair_use_logins
    type: looker_column
    fields:
    - raw_fair_use_logins.distinct_users
    - raw_fair_use_logins._ldts_month
    fill_fields:
    - raw_fair_use_logins._ldts_month
    filters:
      raw_fair_use_logins._ldts_month: after 2018/08/01
      raw_fair_use_logins.message_format_version: ''
      raw_fair_use_logins.message_type: LoginEvent
      raw_fair_use_logins.platform_environment: production
      raw_fair_use_logins.product_platform: cares-dashboard
      raw_fair_use_logins.user_environment: production
    sorts:
    - raw_fair_use_logins._ldts_month desc
    limit: 500
    query_timezone: America/Los_Angeles
    stacking: ''
    show_value_labels: true
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    point_style: none
    series_types: {}
    limit_displayed_rows: false
    limit_displayed_rows_values:
      show_hide: hide
      first_last: last
      num_rows: '1'
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    x_axis_label: Week
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    ordering: none
    show_null_labels: false
    show_dropoff: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    row: 14
    col: 0
    width: 12
    height: 6
  - name: CU Dashboard - WAU
    title: CU Dashboard - WAU
    model: fair_usage
    explore: raw_fair_use_logins
    type: looker_column
    fields:
    - raw_fair_use_logins.distinct_users
    - raw_fair_use_logins._ldts_week
    fill_fields:
    - raw_fair_use_logins._ldts_week
    filters:
      raw_fair_use_logins._ldts_month: after 2018/08/01
      raw_fair_use_logins.message_format_version: ''
      raw_fair_use_logins.message_type: LoginEvent
      raw_fair_use_logins.platform_environment: production
      raw_fair_use_logins.product_platform: cares-dashboard
      raw_fair_use_logins.user_environment: production
    sorts:
    - raw_fair_use_logins._ldts_week desc
    limit: 500
    query_timezone: America/Los_Angeles
    stacking: ''
    show_value_labels: true
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    point_style: none
    series_types: {}
    limit_displayed_rows: true
    limit_displayed_rows_values:
      show_hide: hide
      first_last: last
      num_rows: '1'
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    x_axis_label: Week
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    ordering: none
    show_null_labels: false
    show_dropoff: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    row: 8
    col: 0
    width: 12
    height: 6
  - name: WebAssign
    type: text
    title_text: WebAssign
    subtitle_text: Based user response data - Investigating clear data gaps
    body_text: ''
    row: 36
    col: 0
    width: 24
    height: 2
  - name: WA - DAU
    title: WA - DAU
    model: webassign
    explore: responses
    type: looker_column
    fields:
    - users.distinct_email
    - users.distinct_SSO_GUIDs
    - users.usercount
    - responses.updatedat_date
    fill_fields:
    - responses.updatedat_date
    filters:
      responses.updatedat_date: after 2018/08/01
    sorts:
    - responses.updatedat_date desc
    limit: 500
    query_timezone: America/Los_Angeles
    stacking: ''
    show_value_labels: true
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    point_style: none
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_datetime_label: "%m-%d"
    x_axis_scale: auto
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    hidden_fields:
    - users.distinct_SSO_GUIDs
    - users.usercount
    row: 38
    col: 0
    width: 24
    height: 7
  - name: WA - MAU
    title: WA - MAU
    model: webassign
    explore: responses
    type: looker_column
    fields:
    - users.distinct_email
    - responses.updatedat_month
    - users.distinct_SSO_GUIDs
    - users.usercount
    fill_fields:
    - responses.updatedat_month
    filters:
      responses.updatedat_date: after 2018/08/01
    sorts:
    - responses.updatedat_month desc
    limit: 500
    query_timezone: America/Los_Angeles
    stacking: ''
    show_value_labels: true
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    point_style: none
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    hidden_fields:
    - users.distinct_SSO_GUIDs
    - users.usercount
    row: 45
    col: 12
    width: 12
    height: 8
  - name: WA - WAU
    title: WA - WAU
    model: webassign
    explore: responses
    type: looker_column
    fields:
    - users.distinct_email
    - users.distinct_SSO_GUIDs
    - users.usercount
    - responses.updatedat_week
    fill_fields:
    - responses.updatedat_week
    filters:
      responses.updatedat_date: after 2018/08/01
    sorts:
    - responses.updatedat_week desc
    limit: 500
    query_timezone: America/Los_Angeles
    stacking: ''
    show_value_labels: true
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    point_style: none
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_datetime_label: "%m-%d"
    x_axis_scale: auto
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    hidden_fields:
    - users.distinct_SSO_GUIDs
    - users.usercount
    row: 45
    col: 0
    width: 12
    height: 8
