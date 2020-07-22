#################################################################
# Dockerfile to build bwa, kallisto, cufflinks, MACS2, samtools, 
# picard-tools, fastQC, bedtools, cutadapt, R, ucsc genome tools
# images
# Based on Ubuntu
#  $ cd genomicTools.docker
#  $ VERSION=0.1.0
#  $ docker build -t jianhong/genomictools:$VERSION .  ## --no-cache
#  $ docker images jianhong/genomictools:$VERSION
#  $ docker push jianhong/genomictools:$VERSION
#  $ docker tag jianhong/genomictools:$VERSION jianhong/genomictools:latest
#  $ docker push jianhong/genomictools:latest
#  $ cd ~
#  $ docker pull jianhong/genomictools:latest
#  $ mkdir tmp4genomictools
#  $ docker run -it --rm -e PASSWORD=123456 -p 8787:8787 -v ${PWD}/tmp4genomictools:/home/rstudio jianhong/genomictools:latest
# ## then you can connect the rstudio with localhost:8787 by username: rstudio password:123456
##################################################################
# Set the base image to Ubuntu
FROM bioconductor/bioconductor_docker:RELEASE_3_11

# File/Author / Maintainer
MAINTAINER Jianhong Ou <jianhong.ou@duke.edu>

# envirenment
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH $PATH:/opt/conda/bin

## add ucsc tools
RUN \
  apt-get update --fix-missing && \
  apt-get install --yes rsync && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/ /usr/local/bin/

## add conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

## test conda
#RUN /opt/conda/bin/conda update -y conda

## Install bowtie2, bwa, MACS2, samtools, picard-tools, fastQC, bedtools, cutadapt
RUN /opt/conda/bin/conda install -y -c bioconda bowtie2 bwa macs2 samtools picard fastqc bedtools cutadapt deeptools kallisto trim-galore salmon openssl=1.0

## Install Bioconductor
RUN echo "BiocManager::install(c(\"TxDb.Hsapiens.UCSC.hg38.knownGene\", \"org.Hs.eg.db\", \"TxDb.Drerio.UCSC.danRer10.refGene\", \"org.Dr.eg.db\", \"WriteXLS\", \"ggrepel\"), suppressUpdates=TRUE, ask=FALSE)" | R --vanilla
RUN echo "BiocManager::install(c(\"ChIPpeakAnno\", \"trackViewer\", \"motifStack\", \"ATACseqQC\", \"GeneNetworkBuilder\", \"DESeq2\", \"tximport\", \"pachterlab/sleuth\"), suppressUpdates=TRUE, ask=FALSE)" | R --vanilla
RUN Rscript -e "BiocManager::install('jianhong/genomictools', update = TRUE, ask=FALSE)"


# Define working directory.
WORKDIR /home/rstudio
COPY --chown=rstudio:rstudio . /home/rstudio/

