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
