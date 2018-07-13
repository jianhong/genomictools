#################################################################
# Dockerfile to build bowtie2, tophat2, cufflinks, MACS2, samtools, 
# picard-tools, fastQC, bedtools, cutadapt
# images
# Based on Ubuntu
#  $ cd genomicTools.docker
#  $ VERSION=0.0.3
#  $ docker build -t jianhong/genomictools:$VERSION .
#  $ docker images jianhong/genomictools:$VERSION
#  $ docker push jianhong/genomictools:$VERSION
#  $ docker tag jianhong/genomictools:$VERSION jianhong/genomictools:latest
#  $ docker push jianhong/genomictools:latest
#  $ cd ~
#  $ docker pull jianhong/genomictools:latest
#  $ mkdir tmp4genomictools
#  $ docker run -it --rm -v ${PWD}/tmp4genomictools:/volume/data \
#  $       jianhong/genomictools:latest bash
#  $ docker run -it --rm -v ${PWD}/tmp4genomictools:/volume/data \
#  $     -p 5901:5901 -e USER=root jianhong/genomictools:latest \
#  $     bash -c "service lightdm start && \
#  $     vncserver :1 -geometry 1280x800 -depth 24 && \
#  $     tail -F /root/.vnc/*.log" &
#  $ vnc://`hostname`:5901
##################################################################
# Set the base image to Ubuntu
FROM ubuntu:18.04

# File/Author / Maintainer
MAINTAINER Jianhong Ou <jianhong.ou@duke.edu>

# envirenment
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH $PATH:/opt/conda/bin

# Install LXDE and VNC server
RUN \
  apt-get update --fix-missing && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-mate-core tightvncserver && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
RUN touch /root/.Xresources

# Update the repository sources list, install wget, unzip, curl, git
RUN \
  apt-get update --fix-missing && \
  apt-get install --yes wget bzip2 ca-certificates curl unzip gdebi-core git rsync libssl-dev libcurl4-openssl-dev libgsl-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

## add ucsc tools
RUN rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/ /usr/local/bin/

## add conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

## test conda
RUN /opt/conda/bin/conda update conda

## Install bowtie2, tophat2, cufflinks, MACS2, samtools, picard-tools, fastQC, bedtools, cutadapt
RUN /opt/conda/bin/conda install -y -c bioconda bowtie2 tophat cufflinks macs2 samtools picard fastqc bedtools cutadapt

## Install Trim Galore 
ENV GALORE_VERSION 0.5.0
RUN wget -O TrimGalore.zip https://github.com/FelixKrueger/TrimGalore/archive/{GALORE_VERSION}.zip && \
  unzip TrimGalore.zip && \
  mv TrimGalore-{GALORE_VERSION}/trim_galore /usr/local/bin/ && \
  rm TrimGalore.zip && rm -r TrimGalore-{GALORE_VERSION}

## Install R https://cloud.r-project.org/bin/linux/ubuntu/
RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" | tee /etc/apt/sources.list.d/r.list
RUN \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
  apt-get update --fix-missing && \
  apt-get install -y r-base r-base-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

## Install Bioconductor
RUN echo "source(\"https://bioconductor.org/biocLite.R\")" | R --vanilla
RUN echo "BiocInstaller::biocLite(c(\"ChIPpeakAnno\", \"trackViewer\", \"motifStack\", \"ATACseqQC\", \"GeneNetworkBuilder\", \"TxDb.Hsapiens.UCSC.hg38.knownGene\", \"org.Hs.eg.db\", \"TxDb.Drerio.UCSC.danRer10.refGene\", \"org.Dr.eg.db\"), suppressUpdates=TRUE, ask=FALSE)" | R --vanilla

## Install Rstudio
#RUN \
#  wget https://download2.rstudio.org/rstudio-server-stretch-1.1.453-amd64.deb && \
#  gdebi rstudio-server-stretch-1.1.453-amd64.deb && \
#  rm rstudio-server-stretch-1.1.453-amd64.deb

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

## Install featurecounts
RUN wget https://sourceforge.net/projects/subread/files/subread-1.6.2/subread-1.6.2-source.tar.gz && \
   tar -xzf subread-1.6.2-source.tar.gz && cd subread-1.6.2-source/src && \
   make -f Makefile.Linux && mv ../bin/* /usr/local/bin/ && \
   cd ../.. && rm -r subread-1.6.2-source && rm subread-1.6.2-source.tar.gz


# Define working directory.
WORKDIR /volume/data

# Define default command.
CMD ["bash"]

# Expose ports.
EXPOSE 5901
