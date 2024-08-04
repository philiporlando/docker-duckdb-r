library(targets)
library(qs)


targets::tar_option_set(
  packages = c("tibble"),
  format = "qs"
  # controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
)

targets::tar_source()

list(
  tar_target(
    name = url,
    command = get_medi_cal_managed_care_providers_url()
  ),
  tar_target(
    name = url_modified_time,
    command = get_url_modified_time(url)
  ),
  tar_target(
    name = medi_cal_managed_care_providers_file,
    command = download_medi_cal_managed_care_providers(url, url_modified_time),
    format = "file",
  ),
  tar_target(
    name = duckdb_file,
    command = setup_duckdb()
  ),
  tar_target(
    name = ingested_medi_cal_managed_care_providers,
    command = ingest_medi_cal_managed_care_providers(
      medi_cal_managed_care_providers_file,
      duckdb_file
    )
  )
)
