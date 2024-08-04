transform_data <- function(ingest_hash, duckdb_file) {
  table_name <- "telehealth_by_taxonomy"
  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdb_file)
  df <- dplyr::tbl(con, "medi_cal_managed_care_providers") |>
    dplyr::filter(
      telehealth %in% c("B", "O"),
      !mcna_provider_type %in% c("Other")
    ) |>
    dplyr::group_by(
      taxonomy,
      mcna_provider_type
    ) |>
    dplyr::count(name = "n_telehealth") |>
    dplyr::arrange(desc(n_telehealth)) |>
    dplyr::collect()

  DBI::dbWriteTable(con, table_name, df, overwrite = TRUE)

  hash <- dplyr::tbl(con, table_name) |>
    dplyr::collect() |>
    digest::digest()

  DBI::dbDisconnect(con)
  
  return(hash)
}
