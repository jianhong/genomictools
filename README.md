# genomictools
docker file for genomic tools

Dockerfile to build bwa, bowtie2, kallisto, cufflinks, MACS2, samtools, 
picard-tools, fastQC, bedtools, cutadapt, deeptools, 
R, ucsc genome tools
images
Based on Ubuntu

<pre>
$ cd ~
$ docker pull jianhong/genomictools:latest
$ mkdir tmp4genomictools
$ docker run -e PASSWORD=123456 -p 8787:8787 \
$       -v ${PWD}/tmp4genomictools:/volume/data \
$       jianhong/genomictools:latest

</pre>
