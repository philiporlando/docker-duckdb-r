# Use the official R image as the base
FROM rocker/r-ver:4.1.1

# Set environment variables
ENV RENV_VERSION=1.0.7

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
WORKDIR /usr/src/app

# Copy project files
COPY . .

# Install specific version of renv
RUN R -e "install.packages('renv', repos='https://cloud.r-project.org', type='source', version='${RENV_VERSION}')"

# Restore R packages using renv
RUN R -e "renv::restore()"

# Command to run the targets pipeline
CMD ["Rscript", "--verbose", "run.R"]