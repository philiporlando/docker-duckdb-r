download_data <- function(url, url_modified_time) {
  destfile <- "data/Medi-Cal_Managed_Care_Provider_Listing.csv"
  
  response <- httr2::request(url) |>
    httr2::req_timeout(300) |>
    httr2::req_progress() |>
    httr2::req_perform(destfile) |>
    httr2::resp_check_status()
  
  return(destfile)
}
