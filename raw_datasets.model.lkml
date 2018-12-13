connection: "snowflake_prod"

include: "raw*.view"                       # include all views in this project


explore: raw_mt_resource_interactions {}
