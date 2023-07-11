#################################################################
# Dockerfile to build bwa, kallisto, cufflinks, MACS3, samtools,
# picard-tools, fastQC, bedtools, cutadapt, R, ucsc genome tools
# images
##################################################################
# Set the base image to Ubuntu
FROM bioconductor/bioconductor_docker:devel

# Define working directory.
WORKDIR /home/rstudio

# apply the ownership for rstudio
COPY --chown=rstudio:rstudio . /home/rstudio/

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

## install deeptools, MACS3, ...
RUN pip install deeptools MACS3

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
RUN wget https://github.com/FelixKrueger/TrimGalore/archive/refs/tags/0.6.10.tar.gz && \
    tar -xf 0.6.10.tar.gz && cd TrimGalore-0.6.10 && \
    cp trim_galore /usr/local/sbin/ && cd .. && \
    rm 0.6.10.tar.gz && rm -rf TrimGalore-0.6.10

## install ucsc tools: bedGraphToBigWig, bedToBigBed
RUN wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedGraphToBigWig && \
    chmod +x bedGraphToBigWig && mv bedGraphToBigWig /usr/local/sbin/ && \
    wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedToBigBed && \
    chmod +x bedToBigBed && mv bedToBigBed /usr/local/sbin/

# Install BiocBase
RUN Rscript -e "options(repos = c(CRAN = 'https://cran.r-project.org')); BiocManager::install(ask=FALSE)"

# Install this package and its dependencies
RUN Rscript -e "options(repos = c(CRAN = 'https://cran.r-project.org')); devtools::install('.', dependencies=TRUE, build_vignettes=TRUE, repos = BiocManager::repositories())"

## Install packages in the documentation from Bioconductor
RUN Rscript -e  "BiocManager::install(c('biomaRt', 'dplyr', 'tximport', 'DESeq2', 'DiffBind', 'EnhancedVolcano'), suppressUpdates=TRUE, ask=FALSE)"
#RUN Rscript -e  "BiocManager::install('pachterlab/sleuth', update = TRUE, ask=FALSE)"
RUN Rscript -e "BiocManager::install('rhdf5', update = FALSE, ask=FALSE)"
RUN Rscript -e "BiocManager::install('gridExtra', update = FALSE, ask=FALSE)"
RUN cd ~ && git clone https://github.com/pachterlab/sleuth && \
    sed -i -e 's/importFrom.rhdf5.h5write.default.//' sleuth/NAMESPACE && \
    Rscript -e "devtools::install('sleuth')"

## install phantompeakqualtools
RUN git clone https://github.com/kundajelab/phantompeakqualtools && \
    Rscript -e "install.packages('phantompeakqualtools/spp_1.14.tar.gz')"

RUN path="/usr/local/lib/R/site-library/basicBioinformaticsDRC2023/extdata" && \
    rm -rf ~/sleuth && \
    cp -r $path/RNAseq /home/rstudio/ && \
    cp -r $path/ChIPseq /home/rstudio/

## change the logger-type=stderr to syslog
RUN sed -i 's/stderr/syslog/g' /etc/rstudio/logging.conf
