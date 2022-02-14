# RNI2022 basic bioinformatics

![.github/workflows/push_docker.yaml](https://github.com/jianhong/genomictools/workflows/.github/workflows/push_docker.yaml/badge.svg)

[github page](https://jianhong.github.io/genomictools/) | 
[source code](https://github.com/jianhong/genomictools)

This package will create the docker file for the tools used for RNA-seq and
ChIP-seq analysis, the sample code and files to run the pipeline, and
the slides for the course.

## Pre-requisites
* Basic knowledge of next generation sequence
* Basic knowledge of R
* Basic knowledge of Docker
* A computer with internet connection

## genomictools
docker file for genomic tools

Dockerfile to build bwa, kallisto, MACS2, samtools, 
picard-tools, fastQC, bedtools, cutadapt, deeptools, 
R, ucsc genome tools
images
Based on Ubuntu

This image will not work on M1 chip macbook for RStudio Sever. 
<pre>
$ cd ~
$ docker pull jianhong/genomictools:latest
$ mkdir tmp4genomictools
$ docker run -e PASSWORD=123456 -p 8787:8787 \
$       -v ${PWD}/tmp4genomictools:/data \
$       jianhong/genomictools:latest

</pre>

## pipeline for RNA-seq

The sample RNA-seq data will be analyzed with [kallisto](https://pachterlab.github.io/kallisto/about)
+ [sleuth](https://pachterlab.github.io/sleuth/about),
[kallisto](https://pachterlab.github.io/kallisto/about) or [Salmon](https://combine-lab.github.io/salmon/)
+ [tximport](https://bioconductor.org/packages/tximport/) + [DESeq2](https://bioconductor.org/packages/DESeq2).

## pipeline for ChIP-seq

The ChIP-seq data will be analyzed with [bwa](http://bio-bwa.sourceforge.net/) +
[MACS2](https://github.com/macs3-project/MACS).

## Learning goals

1. Gain the basic knowledge of typical workflows for RNA-seq and ChIP-seq

2. Learn how to understand the results of RNA-seq and ChIP-seq data

3. Become aware the experimental approaches and the limitation of the pipeline.

## references:

* [BioinformaticsTraningWorkshop](https://github.com/haibol2016/BioinformaticsTrainingWorkshop)

* [Introduction to ChIP-seq using high performance computing](https://github.com/hbctraining/Intro-to-ChIPseq)

* [Webinar: New and Improved RNA-Seq Workflows](https://www.rna-seqblog.com/webinar-new-and-improved-rna-seq-workflows/)

* [Alignment-free RNA-seq workflow](https://bioconductor.org/help/course-materials/2017/CSAMA/lectures/2-tuesday/lec07-alignmentfree-rnaseq.pdf)

* [Kallisto and Sleuth](https://scilifelab.github.io/courses/rnaseq/labs/kallisto)

* [cornell computational pipeline for ChIP-seq Data Analysis](https://biohpc.cornell.edu/lab/doc/Chip-seq_workshop_lecture1.pdf)
