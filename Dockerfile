#################################################################
# Dockerfile to build bwa, kallisto, cufflinks, MACS2, samtools, 
# picard-tools, fastQC, bedtools, cutadapt, R, ucsc genome tools
# images
# Based on Ubuntu
#  $ cd genomicTools.docker
#  $ VERSION=0.1.2
#  $ docker build -t jianhong/genomictools:$VERSION .  ## --no-cache
#  $ docker images jianhong/genomictools:$VERSION
#  $ docker push jianhong/genomictools:$VERSION
#  $ docker tag jianhong/genomictools:$VERSION jianhong/genomictools:latest
#  $ docker push jianhong/genomictools:latest
#  $ cd ~
#  $ docker pull jianhong/genomictools:latest
#  $ mkdir tmp4genomictools
#  $ docker run -it --rm --user rstudio -e PASSWORD=123456 -p 8787:8787 -v ${PWD}/tmp4genomictools:/home/rstudio jianhong/genomictools:latest
# ## then you can connect the rstudio with localhost:8787 by username: rstudio password:123456
##################################################################
# Set the base image to Ubuntu
FROM bioconductor/bioconductor_docker:RELEASE_3_14

# File/Author / Maintainer
MAINTAINER Jianhong Ou <jianhong.ou@duke.edu>

# envirenment
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

## install multiple tools
RUN cd ~ && \
    apt-get update --fix-missing && \
    apt-get install --yes rsync wget bzip2 gcc libssl-dev libxml2-dev libncurses5-dev libbz2-dev liblzma-dev libcurl4-openssl-dev librsvg2-dev libv8-dev make cmake build-essential bedtools picard-tools cutadapt python3 python3-pip pandoc fastqc bwa samtools bamtools subread salmon kallisto pigz curl libxml-simple-perl uuid-runtime && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## fix the picard command
RUN wget https://raw.githubusercontent.com/jianhong/chipseq/master/assets/picard -P /usr/bin/ && \
    chmod +x /usr/bin/picard

## install deeptools, MACS2, ...
RUN pip install deeptools MACS2

## install homer
RUN mkdir /homer && cd /homer && \
    wget http://homer.ucsd.edu/homer/configureHomer.pl && \
    perl configureHomer.pl -install
ENV PATH $PATH:/homer/bin

## install je
RUN cd ~ && wget https://raw.githubusercontent.com/gbcs-embl/Je/master/dist/je_2.0.RC.tar.gz && \
    tar -xf je_2.0.RC.tar.gz && cd je_2.0.RC && \
    sed -i "s/bin\/sh/usr\/bin\/env bash/" je && \
    cp * /usr/local/sbin/ && cd .. && rm -rf je*

## install TrimGalore
RUN wget https://github.com/FelixKrueger/TrimGalore/archive/0.6.6.tar.gz && \
    tar -xf 0.6.6.tar.gz && cd TrimGalore-0.6.6 && \
    cp trim_galore /usr/local/sbin/ && cd .. && \
    rm 0.6.6.tar.gz && rm -rf TrimGalore-0.6.6

## install ucsc tools: bedGraphToBigWig, bedToBigBed
RUN wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedGraphToBigWig && \
    chmod +x bedGraphToBigWig && mv bedGraphToBigWig /usr/local/sbin/ && \
    wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedToBigBed && \
    chmod +x bedToBigBed && mv bedToBigBed /usr/local/sbin/

## Install Bioconductor
RUN Rscript -e  "BiocManager::install(c('biomaRt', 'dplyr', 'tximport', 'DESeq2', 'DiffBind', 'EnhancedVolcano'), suppressUpdates=TRUE, ask=FALSE)"
RUN Rscript -e  "BiocManager::install(c('pachterlab/sleuth', update = TRUE, ask=FALSE))"
RUN Rscript -e  "BiocManager::install(c('jianhong/genomictools', update = TRUE, ask=FALSE))"
RUN path="/usr/local/lib/R/site-library/basicBioinformaticsRNI2022/extdata" && \
    cp -r $path/RNAseq /home/rstudio/ && \
    cp -r $path/ChIPseq /home/rstudio/
## install phantompeakqualtools
RUN git clone https://github.com/kundajelab/phantompeakqualtools && \
    Rscript -e "install.packages('phantompeakqualtools/spp_1.14.tar.gz')"

# Define working directory.
WORKDIR /home/rstudio
COPY --chown=rstudio:rstudio . /home/rstudio/

