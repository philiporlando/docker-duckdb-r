# Portable Data pipelines with Docker, DuckDB, and R

This project showcases the integration of Docker, DuckDB, and R to create efficient and portable data pipelines. By using Docker, we ensure a consistent environment across different machines, while DuckDB provides fast, in-process SQL analytics. The R programming language, along with the {duckdb}, {dbplyr}, and {targets} packages, is used to orchestrate and run the data processing tasks. The {renv} package is used alongside Docker to manage R package dependencies, ensuring reproducibility. 

## Getting Started

To get started with this project, clone the repository and navigate to the directory:

```bash
git clone https://github.com/philiporlando/docker-duckdb-r.git
cd docker-duckdb-r
```

## Building the Docker Image

Build the Docker image using the following command. This will set up the necessary R environment, install all dependencies, and prepare the DuckDB database for use. The initial build may take a few minutes to complete.

```bash
docker build .
```

## Running the Container

To run the Docker container and launch the `{targets}` pipeline use:

```bash
docker run
```

## Repository Structure

- `Dockerfile`: Defines the Docker image and specifies how the R environment is built.
- `R/`: Contains R scripts with function definitions used by `{targets}`.
- `data/`: Any source data and the DuckDB database file are stored here.
`tests/`: TBD test suite built around `{testthat}`.
