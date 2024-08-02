# Stage 1: Build base image and install dependencies
FROM rocker/r-ver:4.4.1 AS base

# Set environment variables
ENV WORKDIR=/project
ENV RENV_VERSION=1.0.7
ENV RENV_PATHS_LIBRARY=${WORKDIR}/renv/library
ENV RENV_PATHS_CACHE=${WORKDIR}/renv/.cache

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

FROM base as builder

# Install specific version of renv
RUN R -e "install.packages('renv', repos='https://cloud.r-project.org', type='source', version='${RENV_VERSION}')"

# Copy renv files
# https://rstudio.github.io/renv/articles/docker.html
COPY renv.lock renv.lock
RUN mkdir -p renv
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

# Change default location of cache to project folder
RUN mkdir -p ${RENV_PATHS_CACHE}

# Restore R packages using renv
RUN R -e "renv::restore()"

# Stage 2: final image with application code
FROM base as runner

# Copy files from builder stage
# COPY --from=builder ${WORKDIR} ${WORKDIR}
COPY --from=builder ${RENV_PATHS_CACHE} ${RENV_PATHS_CACHE}
COPY --from=builder ${RENV_PATHS_LIBRARY} ${RENV_PATHS_LIBRARY}

# Copy project files
COPY . ${WORKDIR}

# Command to run the targets pipeline
CMD ["Rscript", "--verbose", "run.R"]