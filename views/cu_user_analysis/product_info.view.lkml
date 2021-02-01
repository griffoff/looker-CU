explore: product_info {hidden:yes}
view: product_info {
  view_label: "Products New"
  sql_table_name: prod.STG_CLTS.PRODUCTS  ;;


   set: curated_fields {fields:[course,edition,productfamily, coursearea, discipline, product, title, count,productfamily_edition,minorsubjectmatter,isbn10,isbn13]}

   set: marketing_fields {fields:[dim_product.coursearea, dim_product.discipline, dim_product.iac_isbn, dim_product.isbn13, dim_product.authors, dim_product.course, dim_product.titleshort, dim_product.productfamily, dim_product.count]}

  # dimension: discipline_rank {description: "Discipline rank by total activations (all time)" type:number group_label:"Product Ranking"}
  # dimension: family_rank {description: "Product family rank by total activations (all time)" type:number group_label:"Product Ranking"}
  # dimension: discipline_rank_6m {description: "Discipline rank by total activations in the last 6 months" type:number group_label:"Product Ranking"}
  # dimension: family_rank_6m {description: "Product family rank by total activations in the last 6 months" type:number group_label:"Product Ranking"}
  # dimension: discipline_rank_mt {description: "Discipline rank by total activations in MindTap" type:number group_label:"Product Ranking"}
  # dimension: family_rank_mt {description: "Product family rank by total activations in MindTap" type:number group_label:"Product Ranking"}

  dimension: platform {}

  dimension: course {
    label: "Course Name"
    group_label: "Product Details"
    type: string
    sql: ${TABLE}.PT_COURSE ;;
    hidden: yes
  }

  dimension: authors {
    type: string
    label: "Authors"
    group_label: "Product Details"
    sql: ${TABLE}.ALL_AUTHORS_NM ;;
    hidden: yes
  }

  dimension: edition {
    type: string
    label: "Edition"
    group_label: "Product Family"
    sql: ${TABLE}.EDITION ;;
    description: "Product edition #"
  }

  # dimension: edition_number {
  #   type:  number
  #   hidden: yes
  # }

  dimension: majorsubjectmatter {
    type: string
    label: "Major Subject Matter"
    group_label: "Subject Matter"
    sql: ${TABLE}.SUB_MATTER_MAJ_DE ;;
    description: "Subject matter (math, economics, science, etc.)"
    hidden: yes
  }

  dimension: minorsubjectmatter {
    type: string
    label: "Minor Subject Matter"
    description: "Brand Discipline"
    group_label: "Subject Matter"
    sql: ${TABLE}.SUB_MATTER_MIN_DE ;;
    hidden: yes
  }

  dimension: mediatype {
    label: "Media Type"
    group_label: "Categories"
    hidden: yes
    type: string
    sql: ${TABLE}.MEDIA_TYPE_DE ;;
  }

  dimension: productfamily {
    type: string
    label: "Product Family"
    group_label: "Product Family"
    description: "Use if data for multiple editions is desired.  This dimension pulls data for all non-filtered editions of a given product family."
    sql: ${TABLE}.PROD_FAMILY_DE ;;
  }

  dimension: productfamily_edition {
    type: string
    label: "Product Family + Edition"
    group_label: "Product Family"
    description: "Use if comparing multiple titles or specific products within a Course Area/Discipline.  This dimension pulls data for a specific combination of product family and edition."
    sql: concat(concat(${productfamily},' - '),${edition});;
  }

  # dimension: publicationgroup {
  #   type: string
  #   label: "Publication Group"
  #   group_label: "Publication Categories"
  #   sql: ${TABLE}.PUBLICATIONGROUP ;;
  # }

  dimension: techproductcode {
    type: string
    hidden: yes
    label: "Tech Product Code"
    group_label: "Categories"
    sql: ${TABLE}.TECH_PROD_CD ;;
  }

  dimension: techproductdescription {
    label: "Tech Product Description"
    group_label: "Categories"
    hidden: yes
    type: string
    sql: ${TABLE}.TECH_PROD_CD_DE ;;
  }

  dimension: coursearea {
    type: string
    label: "Course Area"
    sql: ${TABLE}.PT_COURSE_AREA ;;
    description: "Subject matter: Building Trade, Clinical Psychology, Personal Finance, etc."
    hidden: yes
  }

  dimension: publicationseries {
    type: string
    label: "Publication Series"
    group_label: "Publication Categories"
    sql: ${TABLE}.PUB_SERIES_DE ;;
    hidden: yes
  }
  dimension: discipline {
    description: "Subject matter: Art, Philosophy, Criminal Justice, etc."
    type: string
    label: "Discipline"
    sql: ${TABLE}.DISCIPLINE_DE;;
    drill_fields: [productfamily]
  }

  # measure: discipline_rank_2 {
  #   label: "Discipline - Rank 2"
  #   group_label: "Categories"
  #   type: string
  #   sql:
  #     CASE
  #     WHEN row_number() over (order by SUM(noofactivations) desc)
  #     <20 THEN '0-20'
  #     WHEN row_number() over (order by SUM(noofactivations) desc)
  #     <80 THEN '20-80'
  #     ELSE '>80'
  #     END;;
  #   hidden: yes
  # }


  # dimension: discipline_old {
  #   type: string
  #   hidden: yes
  #   label: "Discipline (Old)"
  #   group_label: "Categories"
  #   sql: ${TABLE}.DISCIPLINE ;;

  # }

  dimension: coursearea_pt {
    type: string
    hidden: yes
    label: "Course Area (Pubtrack)"
    group_label: "Pubtrack Categories"
    sql: ${TABLE}.PT_COURSE_AREA ;;
  }

  dimension: discipline_pt {
    type: string
    hidden: yes
    label: "Discipline (Pubtrack)"
    group_label: "Pubtrack Categories"
    sql: ${TABLE}.PT_DISCIPLINE ;;
  }

  dimension: division_cd {
    label: "Division Code"
    group_label: "Sales Division"
    type: string
    sql: ${TABLE}.DIVISION_CD ;;
    description: "Sales division code"
    hidden: yes
  }

  dimension: division_de {
    type: string
    label: "Division Description"
    group_label: "Sales Division"
    sql: ${TABLE}.DIVISION_DE ;;
    description: "Sales division description (STM, Skills, K12, etc.)"
    hidden: yes
  }

  # dimension: dw_ldid {
  #   type: string
  #   sql: ${TABLE}.DW_LDID ;;
  #   hidden: yes
  # }

  dimension_group: dw_ldts {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.LDTS ;;
    hidden: yes
  }

  # dimension: iac_isbn {
  #   description: "This is the digital product. This ISBN is purchased with a transaction, the ISBN linked to an Access Code, and the ISBN Courses are built on.
  #   These have search metadata added in business systems, and are indexed by the various catalogs.
  #   The IAC ISBN will be a sub-product to a Core/Title ISBN. There can be multiple IAC ISBNs associated with a single Core,
  #   but an IAC ISBN itself can have only ONE Core ISBN. IAC ISBN may have one or multiple Component ISBNs in its Bill of Materials."
  #   type: string
  #   label: "IAC ISBN"
  #   group_label: "ISBN"
  #   sql: ${TABLE}.IAC_ISBN ;;
  # }

  dimension: isbn10 {
    description: "These are individual products inside of an IAC.  These are MindTap products, Coursemate, CNOW, Aplia, ebooks, recourse centers, mobile apps, etc.
    One component ISBN may be part of multiple IACs. Only one Courseware Component ISBN product may exist in an IAC.
    But that component can be in multiple IACs that have different shared components along with it that are also Component ISBNs."
    type: string
    label: "ISBN10"
    group_label: "ISBN"
    sql: ${TABLE}.ISBN10 ;;
    hidden: yes
  }

  dimension: isbn13 {
    type: string
    label: "ISBN13"
    # group_label: "ISBN"
    sql: ${TABLE}.ISBN13 ;;
    primary_key: yes
    description: "Product ISBN13"
  }

  # dimension: mindtap_isbn {
  #   description: "Do not use for analysis.  Mindtap ISBN dimension is available to help confirm what the correct IAC ISBN or ISBN13 should be."
  #   type: string
  #   label: "Mindtap ISBN"
  #   group_label: "ISBN"
  #   sql: ${TABLE}.MINDTAP_ISBN ;;
  # }

  # dimension: pac_isbn {
  #   description: "This is the ISBN of a physical Printed Access Card, similar to how a physical workbook would have a unique ISBN.  Printed on this card is a single Access Code that has been generated from an IAC ISBN."
  #   type: string
  #   label: "PAC ISBN"
  #   group_label: "ISBN"
  #   sql: ${TABLE}.PAC_ISBN ;;
  # }

  # dimension: public_coretext_isbn {
  #   description: "Do not use for analysis.  CoreText ISBN dimension is available to help confirm what the correct IAC ISBN or ISBN13 should be."
  #   type: string
  #   label: "Public CoreText ISBN"
  #   group_label: "ISBN"
  #   sql: ${TABLE}.PUBLIC_CORETEXT_ISBN ;;
  # }

  # dimension: editionrecency {
  #   label: "Edition List"
  #   description: "Relative edition index - latest edition is always 1, the previous edition 2, and so on.
  #   e.g.
  #   - Product Family X has editions 001, 002, 003
  #   - Edition List will be 3, 2, 1
  #   "
  #   type: number
  #   group_label: "Product Details"
  #   sql: ${TABLE}.latest ;;
  # }

  # dimension: islatestedition {
  #   label: "Current Edition"
  #   description: "Flag that can be used as a filter to only look at the latest edition of a given product."
  #   type: yesno
  #   group_label: "Product Details"
  #   #sql: ${TABLE}.ISLATESTEDITION ;;
  #   sql: ${editionrecency} = 1 ;;
  # }

  # dimension_group: loaddate {
  #   type: time
  #   timeframes: [time, date, week, month]
  #   sql: ${TABLE}.LOADDATE ;;
  #   hidden: yes
  # }

  dimension: product {
    type: string
    label: "Product Name"
    group_label: "Product Details"
    sql: ${TABLE}.TITLE ;;
  }

  # dimension: product_skey {
  #   type: string
  #   sql: ${TABLE}.PRODUCT_SKEY ;;
  #   hidden: yes
  # }

  dimension: title {
    type: string
    label: "Product Title"
    group_label: "Product Details"
    sql: ${TABLE}.TITLE ;;
  }

  dimension: titleshort {
    type: string
    label: "Product Title (Short)"
    group_label: "Product Details"
    sql: ${TABLE}.SHORT_TITLE ;;
  }

  # dimension: productid {
  #   type: string
  #   sql: ${TABLE}.PRODUCTID ;;
  #   primary_key: yes
  #   hidden: yes
  # }

  measure: count_disciplines {
    label: "# Disciplines"
    type: count_distinct
    sql: ${discipline} ;;
    description: "Count of distinct disciplines shown in a given view"
    hidden: yes
  }

  measure: count_product_family {
    label: "# Product Families"
    type: count_distinct
    sql: ${productfamily} ;;
    description: "Count of distinct product families shown in a given view"
    hidden: yes
  }

  measure: count {
    label: "# Products"
    description: "Count of the number of products included in a given view.
    This measure is only relevant at a high-level (e.g. for an institution).  At a low (e.g. course key) level, this measure has limited value."
    type: count
    drill_fields: []
  }

   }
