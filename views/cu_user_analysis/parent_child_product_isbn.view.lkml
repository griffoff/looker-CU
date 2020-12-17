view: parent_child_product_isbn {
  derived_table: {
    sql:
      select hi.ISBN13 as parent_isbn, hi2.ISBN13 as child_isbn, hash(hi.isbn13,hi2.isbn13) as pk
      from prod.DATAVAULT.HUB_ISBN hi
      inner join prod.DATAVAULT.LINK_PRODUCT_ISBN lpi on lpi.HUB_ISBN_KEY = hi.HUB_ISBN_KEY
      inner join prod.DATAVAULT.SAT_PRODUCT_ISBN_EFFECTIVITY spie on spie.LINK_PRODUCT_ISBN_KEY = lpi.LINK_PRODUCT_ISBN_KEY and spie._EFFECTIVE
      inner join prod.DATAVAULT.LINK_PRODUCT_RELATIONSHIP lpr1 on lpr1.HUB_parent_PRODUCT_KEY = lpi.HUB_PRODUCT_KEY
      inner join prod.DATAVAULT.LINK_PRODUCT_ISBN lpi2 on lpi2.HUB_PRODUCT_KEY = lpr1.HUB_child_PRODUCT_KEY
      inner join prod.DATAVAULT.SAT_PRODUCT_ISBN_EFFECTIVITY spie2 on spie2.LINK_PRODUCT_ISBN_KEY = lpi.LINK_PRODUCT_ISBN_KEY and spie2._EFFECTIVE
      inner join prod.DATAVAULT.HUB_ISBN hi2 on hi2.HUB_ISBN_KEY = lpi2.HUB_ISBN_KEY
      union
      select hi.isbn13, hi.isbn13, hash(hi.isbn13, hi.isbn13)
      from prod.DATAVAULT.HUB_ISBN hi

      union
      (
      select hi.isbn13, spa.attr_value, hash(hi.isbn13, spa.attr_value)
      from prod.DATAVAULT.HUB_ISBN hi
      inner join prod.DATAVAULT.LINK_PRODUCT_ISBN lpi on lpi.HUB_ISBN_KEY = hi.HUB_ISBN_KEY
      inner join prod.DATAVAULT.SAT_PRODUCT_ATTR spa on spa.HUB_PRODUCT_KEY = lpi.HUB_PRODUCT_KEY
      WHERE spa.ATTR_TYPE_ID = 'TITLE_ISBN'
      QUALIFY ROW_NUMBER() OVER (PARTITION BY spa.HUB_PRODUCT_KEY, spa.ATTR_TYPE_ID ORDER BY spa.RSRC_TIMESTAMP DESC) = 1
      )

    ;;
    persist_for: "8 hours"
  }

  dimension: pk {hidden:yes primary_key:yes}
  dimension: parent_isbn {hidden:yes}
  dimension: child_isbn {hidden:yes}
}
