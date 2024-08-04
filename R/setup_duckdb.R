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
