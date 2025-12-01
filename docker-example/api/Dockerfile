# R Plumber API Container
FROM rocker/r-ver:4.5.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    zlib1g-dev \
    libsodium-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('plumber', 'jsonlite', 'dplyr'), repos='https://cloud.r-project.org/')"

# Create app directory
WORKDIR /app

# Copy API files
COPY plumber.R /app/
COPY patients_data.csv /app/

# Expose port
EXPOSE 8000

# Run plumber API
CMD ["R", "-e", "pr <- plumber::plumb('plumber.R'); pr$run(host='0.0.0.0', port=8000)"]
