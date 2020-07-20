#################################################################
# Dockerfile to build bowtie2, tophat2, cufflinks, MACS2, samtools, 
# picard-tools, fastQC, bedtools, cutadapt, R, ucsc genome tools
# images
# Based on Ubuntu
#  $ cd genomicTools.docker
#  $ VERSION=0.0.6
#  $ docker build -t jianhong/genomictools:$VERSION .  ## --no-cache
#  $ docker images jianhong/genomictools:$VERSION
#  $ docker push jianhong/genomictools:$VERSION
#  $ docker tag jianhong/genomictools:$VERSION jianhong/genomictools:latest
#  $ docker push jianhong/genomictools:latest
#  $ cd ~
#  $ docker pull jianhong/genomictools:latest
#  $ mkdir tmp4genomictools
#  $ docker run -it --rm -v ${PWD}/tmp4genomictools:/volume/data \
#  $     -p 5901:5901 -e USER=root jianhong/genomictools:latest \
#  $     bash -c "service lightdm start && \
#  $     vncserver :1 -geometry 1280x800 -depth 24 && \
#  $     tail -F /root/.vnc/*.log" &
#  $ vnc://`hostname`:5901
#  $ docker run -it --rm -p 8787:8787 -v ${PWD}/tmp4genomictools:/home/rstudio jianhong/genomictools:latest
# ## then you can connect the rstudio with localhost:8787 by username: rstudio password:123456
##################################################################
# Set the base image to Ubuntu
FROM ubuntu:latest

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
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

## test conda
#RUN /opt/conda/bin/conda update -y conda

## Install bowtie2, tophat2, cufflinks, MACS2, samtools, picard-tools, fastQC, bedtools, cutadapt
RUN /opt/conda/bin/conda install -y -c bioconda bowtie2 tophat cufflinks macs2 samtools picard fastqc bedtools cutadapt deeptools

## Install Trim Galore 
ENV GALORE_VERSION 0.6.4
RUN wget -O TrimGalore.zip https://github.com/FelixKrueger/TrimGalore/archive/${GALORE_VERSION}.zip && \
  unzip TrimGalore.zip && \
  mv TrimGalore-${GALORE_VERSION}/trim_galore /usr/local/bin/ && \
  rm TrimGalore.zip && rm -r TrimGalore-${GALORE_VERSION}

## Install R https://cloud.r-project.org/bin/linux/ubuntu/
RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" | tee /etc/apt/sources.list.d/r.list
RUN \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
  apt-get update --fix-missing && \
  apt-get install -y r-base r-base-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

## Install Bioconductor
RUN echo "install.packages('BiocManager', repos='https://cloud.r-project.org')" | R --vanilla
RUN echo "BiocManager::install(c(\"TxDb.Hsapiens.UCSC.hg38.knownGene\", \"org.Hs.eg.db\", \"TxDb.Drerio.UCSC.danRer10.refGene\", \"org.Dr.eg.db\", \"WriteXLS\", \"ggrepel\"), suppressUpdates=TRUE, ask=FALSE)" | R --vanilla
RUN echo "BiocManager::install(c(\"ChIPpeakAnno\", \"trackViewer\", \"motifStack\", \"ATACseqQC\", \"GeneNetworkBuilder\", \"DESeq2\"), suppressUpdates=TRUE, ask=FALSE)" | R --vanilla

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

## Install Rstudio
RUN \
  apt-get update --fix-missing && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y libclang-dev pandoc texlive-base texlive-extra-utils texlive-font-utils texlive-fonts-recommended texlive-latex-base texlive-latex-extra texlive-latex-recommended texlive-pictures texlive-plain-generic texlive-pstricks && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV RSTUDIO_VERSION 1.2.1335
RUN \
  wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb && \
  gdebi -n rstudio-server-${RSTUDIO_VERSION}-amd64.deb && \
  rm rstudio-server-${RSTUDIO_VERSION}-amd64.deb && \
  echo "server-app-armor-enabled=0" >> /etc/rstudio/rserver.conf && \
  useradd -m rstudio && echo rstudio:123456 | chpasswd

# Define working directory.
WORKDIR /volume/data

# Define default command.
CMD ["bash"]

# Expose ports.
EXPOSE 5901

## start rstudio
ENTRYPOINT rstudio-server start && bash
