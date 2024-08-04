get_medi_cal_managed_care_providers_url <- function() {
  url <- "https://gis.dhcs.ca.gov/api/download/v1/items/d2e10fb206454d88813a45e0a42a1ea4/csv?layers=0"
  return(url)
}

get_url_modified_time <- function(url) {
    response <- httr2::request(url) |>
      httr2::req_method(method = "HEAD") |>
      httr2::req_perform() |>
      httr2::resp_check_status()
    
    url_modified_time <- response |> 
      httr2::resp_header(header = "Last-Modified") |>
      lubridate::parse_date_time(orders = "a, d b Y H:M:S", tz = "GMT")

  return(url_modified_time)
}

download_medi_cal_managed_care_providers <- function(url, url_modified_time) {
  destfile <- "data/Medi-Cal_Managed_Care_Provider_Listing.csv"
  
  response <- httr2::request(url) |>
    httr2::req_timeout(300) |>
    httr2::req_progress() |>
    httr2::req_perform(destfile) |>
    httr2::resp_check_status()
  
  return(destfile)
}

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

ingest_medi_cal_managed_care_providers <- function(source_file, duckdb_file) {
  table_name <- "medi_cal_managed_care_providers"
  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdb_file)

  df <- readr::read_csv(
    source_file,
    col_types = readr::cols(.default = readr::col_character()),
    n_max = 1000
  ) |>
    janitor::clean_names()

  DBI::dbWriteTable(con, table_name, df, overwrite = TRUE)

  hash <- dplyr::tbl(con, table_name) |>
    dplyr::collect() |>
    digest::digest()

  DBI::dbDisconnect(con)

  return(hash)
}
