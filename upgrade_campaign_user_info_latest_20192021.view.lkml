view: upgrade_campaign_user_info_latest_20192021 {
  derived_table: {
    sql: SELECT * FROM uploads.zpg.userinfo
      ;;
  }

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
    hidden: yes
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
    hidden: yes
  }

  dimension: segment {
    type: string
    sql: ${TABLE}."SEGMENT" ;;
    hidden: yes
  }

  dimension: guid {
    type: string
    sql: ${TABLE}."GUID" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: no_contact {
    type: string
    sql: ${TABLE}."NO_CONTACT" ;;
  }

  dimension: opt_out {
    type: string
    sql: ${TABLE}."OPT_OUT" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: optout {
    type: string
    sql: ${TABLE}."OPTOUT" ;;
    hidden: yes
  }

  dimension: firstname {
    type: string
    sql: ${TABLE}."FIRSTNAME" ;;
    hidden: yes
  }

  dimension: count {
    type: number
    sql: ${TABLE}."COUNT" ;;
    hidden: yes
  }

  dimension: nocontact {
    type: string
    sql: ${TABLE}."NOCONTACT" ;;
    hidden: yes
  }

  dimension: lastname {
    type: string
    sql: ${TABLE}."LASTNAME" ;;
    hidden: yes
  }

  set: detail {
    fields: [
      _file,
      _line,
      segment,
      guid,
      email,
      no_contact,
      opt_out,
      last_name,
      first_name,
      optout,
      firstname,
      count,
      nocontact,
      lastname
    ]
  }
}
