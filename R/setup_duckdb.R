setup_duckdb <- function() {
  duckdb_file <- "data/database.duckdb"

  if (!file.exists(duckdb_file)) {
    con <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdb_file)
    DBI::dbDisconnect(con, shutdown = TRUE)
  }

  return(duckdb_file)
}
