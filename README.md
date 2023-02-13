[![Docker Image CI](https://github.com/mattgalbraith/fastqc-docker-singularity/actions/workflows/docker-image.yml/badge.svg)](https://github.com/mattgalbraith/samtools-fastqc-singularity/actions/workflows/docker-image.yml)
# fastqc-docker-singularity
## Build Docker container for FastQC software and (optionally) convert to Apptainer/Singularity.  
FastQC aims to provide a simple way to do some quality control checks on raw sequence data coming from high throughput sequencing pipelines.  

## Build docker container:  

Not using Conda to keep image size small.  
### 1. For FastQC installation instructions:  
https://www.bioinformatics.babraham.ac.uk/projects/download.html#fastqc  
See also:
https://github.com/s-andrews/FastQC  


### 2. Build the Docker Image

#### To build image from the command line:  
``` bash
# Assumes current working directory is the top-level fastqc-docker-singularity directory
docker build -t fastqc:0.11.9 . # tag should match software version
```
* Can do this on [Google shell](https://shell.cloud.google.com)

#### To test this tool from the command line:

``` bash
docker run --rm -it fastqc:0.11.9 fastqc --help

# Optional: Run with test data from PICARD Test Data GCS bucket
# mkdir fastq_test && gsutil cp gs://gatk-test-data/wgs_fastq/NA12878_20k/H06HDADXX130110.1.ATCACGAT.20k_reads_1.fastq ./fastq_test/ && gzip fastq_test/*.fastq
docker run -it --rm -v "$PWD":/data -w /data fastqc:test2 fastqc fastq_test/H06HDADXX130110.1.ATCACGAT.20k_reads_1.fastq.gz --outdir=fastq_test
# -v mounts current working dir as /data in container
# -w sets working dir in conatiner
# SUCCESSFUL TEST RESULT: html reports and zip files of results in /fastq_test for 2x 10k reads
```

## Optional: Conversion of Docker image to Singularity  

### 3. Build a Docker image to run Singularity  
(skip if this image is already on your system)  
https://github.com/mattgalbraith/singularity-docker

### 4. Save Docker image as tar and convert to sif (using singularity run from Docker container)  
``` bash
docker images
docker save <Image_ID> -o fastqc-docker.tar && gzip fastqc-docker.tar # = IMAGE_ID of fastqc image
docker run -v "$PWD":/data --rm -it singularity bash -c "singularity build /data/fastqc.sif docker-archive:///data/fastqc-docker.tar"
```
NB: On Apple M1/M2 machines ensure Singularity image is built with x86_64 architecture or sif may get built with arm64  

Next, transfer the fastqc.sif file to the system on which you want to run FastQC from the Singularity container  

### 5. Test singularity container on (HPC) system with Singularity/Apptainer available  
``` bash
# set up path to the FastQC Singularity container
FASTQC_SIF=path/to/fastqc.sif

# Test that FASTQC can run from Singularity container
singularity run $FASTQC_SIF fastqc --help # depending on system/version, singularity may be called apptainer
```
