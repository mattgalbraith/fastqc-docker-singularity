################## BASE IMAGE ######################
# FROM alpine as base
FROM ubuntu:20.04 as base

################## METADATA ######################
LABEL base_image="Ubuntu:20.04"
LABEL version="1"
LABEL software="FastQC"
LABEL software.version="0.11.9"
LABEL about.summary="FastQC aims to provide a simple way to do some quality control checks on raw sequence data coming from high throughput sequencing pipelines."
LABEL about.home="https://www.bioinformatics.babraham.ac.uk/projects/fastqc/"
LABEL about.documentation="https://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/"
LABEL about.license_file="https://github.com/s-andrews/FastQC/blob/master/LICENSE"
LABEL about.license="GNU GPL v3"

################## MAINTAINER ######################
MAINTAINER Matthew Galbraith <matthew.galbraith@cuanschutz.edu>

################## INSTALLATION ######################
# ARG ENV_NAME="fastqc"
# ARG FASTQC_VERSION="0.11.9"
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES unzip
# add wget if downloading fastqc_v0.11.9.zip directly

RUN apt-get update && \
    apt-get install -y --no-install-recommends ${PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Get and unzip fastqc
COPY fastqc_v0.11.9.zip /
RUN unzip fastqc_v0.11.9.zip \
	&& rm fastqc_v0.11.9.zip

# # Download and unzip FastQC
# RUN wget --no-check-certificate https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip \
#     && unzip fastqc_v0.11.9.zip \
#     && rm fastqc_v0.11.9.zip

################## 2ND STAGE ######################
FROM ubuntu:20.04
# ARG ENV_NAME="fastqc"
# ARG FASTQC_VERSION="0.11.9"
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES unzip default-jre libfindbin-libs-perl
# https://biodockerfiles.github.io/fastqc-0-11-9/ also adds: libcommons-math3-java libhtsjdk-java libjbzip2-java

RUN apt-get update && \
    apt-get install -y --no-install-recommends ${PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=base /FastQC/ /FastQC/

# Make the FastQC code executable and global
RUN chmod +x /FastQC/fastqc \
    && ln -s /FastQC/fastqc /usr/local/bin/fastqc