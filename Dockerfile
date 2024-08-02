# Stage 1: Build base image and install dependencies
FROM rocker/r-ver:4.4.1 AS builder

# Set environment variables
ENV WORKDIR=/project
ENV RENV_VERSION=1.0.7
ENV RENV_PATHS_LIBRARY renv/library

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    cmake \
    libmbedtls-dev \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR ${WORKDIR}

# Copy renv files
# https://rstudio.github.io/renv/articles/docker.html
COPY renv.lock renv.lock
RUN mkdir -p renv
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

# Change default location of cache to project folder
RUN mkdir renv/.cache
ENV RENV_PATHS_CACHE renv/.cache

# Install specific version of renv
RUN R -e "install.packages('renv', repos='https://cloud.r-project.org', type='source', version='${RENV_VERSION}')"

# Restore R packages using renv
RUN R -e "renv::restore()"

# Stage 2: final image with application code
FROM rocker/r-ver:4.4.1

WORKDIR ${WORKDIR}
COPY --from=builder ${WORKDIR} .

# Copy project files
COPY . .

# Command to run the targets pipeline
CMD ["Rscript", "--verbose", "run.R"]