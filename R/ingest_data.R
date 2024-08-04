setup_duckdb <- function() {
  duckdb_dir <- "data"
  duckdb_file <- file.path(duckdb_dir, "database.duckdb")
  
  if (!dir.exists(duckdb_dir)) {
    dir.create(duckdb_dir, recursive = TRUE)
  }
  
  if (!file.exists(duckdb_file)) {
    con <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdb_file)
    DBI::dbDisconnect(con, shutdown = TRUE)
  }

  return(duckdb_file)
}

ingest_data <- function(source_file, duckdb_file) {
  table_name <- "medi_cal_managed_care_providers"
  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdb_file)

  # importing directly from duckdb is ideal, but read_csv() was raising parsing errors...
  df <- readr::read_csv(
    source_file,
    col_types = readr::cols(
      .default = readr::col_character()
    ),
  ) |>
    janitor::clean_names()

  DBI::dbWriteTable(con, table_name, df, overwrite = TRUE)

  hash <- dplyr::tbl(con, table_name) |>
    dplyr::collect() |>
    digest::digest()

  DBI::dbDisconnect(con)

  return(hash)
}
