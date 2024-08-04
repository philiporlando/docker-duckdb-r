get_data_url <- function() {
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

download_data <- function(url, url_modified_time) {
  destfile <- "data/Medi-Cal_Managed_Care_Provider_Listing.csv"
  
  response <- httr2::request(url) |>
    httr2::req_timeout(300) |>
    httr2::req_progress() |>
    httr2::req_perform(destfile) |>
    httr2::resp_check_status()
  
  return(destfile)
}
