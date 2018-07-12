# genomictools
docker file for genomic tools

Dockerfile to build bowtie2, tophat2, cufflinks, MACS2, samtools, 
picard-tools, fastQC, bedtools, cutadapt
images
Based on Ubuntu

<pre>
$ cd genomicTools.docker
$ VERSION=0.0.1
$ docker build -t jianhong/genomictools:$VERSION .
$ docker images jianhong/genomictools:$VERSION
$ docker push jianhong/genomictools:$VERSION
$ docker tag jianhong/genomictools:$VERSION jianhong/genomictools:latest
$ docker push jianhong/genomictools:latest
$ cd ~
$ docker pull jianhong/genomictools:latest
$ mkdir tmp4genomictools
$ docker run -it --rm -v ${PWD}/tmp4genomictools:/volume/data \
$       jianhong/genomictools:latest bash
$ docker run -it --rm -v ${PWD}/tmp4genomictools:/volume/data \
$     -p 5901:5901 -e USER=root jianhong/genomictools:latest \
$     bash -c "service lightdm start && \
$     vncserver :1 -geometry 1280x800 -depth 24 && \
$     tail -F /root/.vnc/*.log" &
$ vnc://`hostname`:5901
</pre>