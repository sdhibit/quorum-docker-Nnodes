FROM ubuntu:16.04 as builder

RUN apt-get update && \
    apt-get install -y \
            build-essential \
            curl \
            libdb-dev \
            libleveldb-dev \
            libsodium-dev \
            libtinfo-dev \
            sysvbanner \
            tar \
            wrk \
            zlib1g-dev

ARG CONSTELLATION_VERSION=0.3.2
ARG CONSTELLATION_BASEURL="https://github.com/jpmorganchase/constellation/archive"
ARG CONSTELLATION_PKGNAME="v${CONSTELLATION_VERSION}.tar.gz"
ARG CONSTELLATION_URL="${CONSTELLATION_BASEURL}/${CONSTELLATION_PKGNAME}"

ARG QUORUM_VERSION=2.0.2

RUN curl -sSL https://get.haskellstack.org/ | sh \
 && mkdir /constellation \
 && curl -kL ${CONSTELLATION_URL} | tar -xz -C /constellation --strip-components=1 

WORKDIR /work

#RUN wget -q https://github.com/jpmorganchase/constellation/releases/download/v$CONSTELLATION_VERSION/constellation-$CONSTELLATION_VERSION-ubuntu1604.tar.xz && \
#    tar -xvf constellation-$CONSTELLATION_VERSION-ubuntu1604.tar.xz && \
#    cp constellation-$CONSTELLATION_VERSION-ubuntu1604/constellation-node /usr/local/bin && \
#    chmod 0755 /usr/local/bin/constellation-node && \
#    rm -rf constellation-$CONSTELLATION_VERSION-ubuntu1604.tar.xz constellation-$CONSTELLATION_VERSION-ubuntu1604

#ENV GOREL go1.7.3.linux-amd64.tar.gz
#ENV PATH $PATH:/usr/local/go/bin

#RUN wget -q https://storage.googleapis.com/golang/$GOREL && \
#    tar xfz $GOREL && \
#    mv go /usr/local/go && \
#    rm -f $GOREL

#RUN git clone https://github.com/jpmorganchase/quorum.git && \
#    cd quorum && \
#    wget https://github.com/jpmorganchase/quorum/commit/bcf82ca2b9ac4bf78ede873a6230ece497e10052.patch -O fix_428.patch && \
#    patch -p1 < fix_428.patch && \
#    git checkout tags/v$QUORUM_VERSION && \
#    make all && \
#    cp build/bin/geth /usr/local/bin && \
#    cp build/bin/bootnode /usr/local/bin && \
#    cd .. && \
#    rm -rf quorum

### Create the runtime image, leaving most of the cruft behind (hopefully...)

#FROM ubuntu:16.04

# Install add-apt-repository
#RUN apt-get update && \
#    apt-get install -y --no-install-recommends software-properties-common && \
#    add-apt-repository ppa:ethereum/ethereum && \
#    apt-get update && \
#    apt-get install -y --no-install-recommends \
#        libdb-dev \
#        libleveldb-dev \
#        libsodium-dev \
#        zlib1g-dev\
#        libtinfo-dev \
#        solc && \
#    rm -rf /var/lib/apt/lists/*

# Temporary useful tools
#RUN apt-get update && \
#        apt-get install -y iputils-ping net-tools vim

#COPY --from=builder \
#        /usr/local/bin/constellation-node \
#        /usr/local/bin/geth \
#        /usr/local/bin/bootnode \
#    /usr/local/bin/

#CMD ["/qdata/start-node.sh"]