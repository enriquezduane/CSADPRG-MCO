FROM r-base:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev

# Create and set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.R /app/
COPY src/ /app/src/

# Install R packages
RUN Rscript requirements.R

# Command to run the script
CMD ["Rscript", "src/main.R"]
