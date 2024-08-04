# Stage 1: Build base image and install dependencies
FROM rocker/r-ver:4.4.1 AS base

# Set environment variables
ENV WORKDIR=/project
ENV RENV_VERSION=1.0.7
ENV RENV_DIR=${WORKDIR}/renv
ENV RENV_PATHS_LIBRARY=${RENV_DIR}/library
ENV RENV_PATHS_CACHE=${RENV_DIR}/.cache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    cmake \    
    libcurl4-openssl-dev \
    libmbedtls-dev \
    libssl-dev \
    libxml2-dev \
    tree \
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
COPY .Rprofile .Rprofile
RUN mkdir -p renv
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

# Change default location of cache to project folder
RUN mkdir ${RENV_PATHS_CACHE}
RUN mkdir ${RENV_PATHS_LIBRARY}

# Restore R packages using renv
RUN R -e "renv::restore()"

# Stage 2: final image with application code
FROM base as runner

# Set the working directory
WORKDIR ${WORKDIR}

# Copy files from builder stage
COPY --from=builder ${WORKDIR} .

# Copy project files
COPY _targets _targets
COPY _targets.R _targets.R 
COPY R R
COPY run.R run.R

# Restore R packages from the builder stage's cache
# TODO renv would install again within the runner stage?
# RUN R -e "renv::restore()"

# Command to run the targets pipeline
CMD ["Rscript", "--verbose", "run.R"]