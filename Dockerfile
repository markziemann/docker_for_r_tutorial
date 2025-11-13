FROM bioconductor/bioconductor_docker:3.21-R-4.5.2

# Update apt-get
RUN apt-get update -y \
        && apt-get upgrade -y \
        && apt-get install -y nano git x11-apps \
        ## Remove packages in '/var/cache/' and 'var/lib'
        ## to remove side-effects of apt-get update
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Install CRAN packages
RUN Rscript -e 'install.packages(c("gplots","eulerr","kableExtra"))'

# Install bioconductor packages
RUN Rscript -e 'BiocManager::install(c("getDEE2","DESeq2"))'

# get a clone of the codes using HTTPS
RUN git clone https://github.com/markziemann/docker_for_r_tutorial.git

# Set the container working directory
ENV DIRPATH=/docker_for_r_tutorial
WORKDIR $DIRPATH
