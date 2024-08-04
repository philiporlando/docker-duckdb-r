library(targets)
library(qs)


targets::tar_option_set(
  packages = c("tibble"),
  format = "qs"
)

targets::tar_source()

list(
  tar_target(
    name = data_url,
    command = get_data_url()
  ),
  tar_target(
    name = url_modified_time,
    command = get_url_modified_time(data_url)
  ),
  tar_target(
    name = raw_data_file,
    command = download_data(data_url, url_modified_time),
    format = "file",
  ),
  tar_target(
    name = duckdb_file,
    command = setup_duckdb()
  ),
  tar_target(
    name = ingested_data,
    command = ingest_data(
      raw_data_file,
      duckdb_file
    )
  ),
  tar_target(
    name = transformed_data,
    command = transform_data(
      ingested_data,
      duckdb_file
    )
  )
)
