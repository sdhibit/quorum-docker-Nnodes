FROM ubuntu:16.04 as builder

WORKDIR /work

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

ENV PATH $PATH:/usr/local/go/bin

ARG TESSERA_VERSION=0.6
ARG TESSERA_BASEURL="https://github.com/jpmorganchase/tessera/releases/download"
ARG TESSERA_PKGNAME="tessera-${TESSERA_VERSION}/tessera-app-${TESSERA_VERSION}-app.jar"
ARG TESSERA_URL="${TESSERA_BASEURL}/${TESSERA_PKGNAME}"

ARG GO_VERSION=1.11
ARG GO_BASEURL="https://dl.google.com/go"
ARG GO_PKGNAME="go${GO_VERSION}.linux-amd64.tar.gz"
ARG GO_URL="${GO_BASEURL}/${GO_PKGNAME}"

ARG QUORUM_VERSION=2.1.0
ARG QUORUM_BASEURL="https://github.com/jpmorganchase/quorum/archive"
ARG QUORUM_PKGNAME="v${QUORUM_VERSION}.tar.gz"
ARG QUORUM_URL="${QUORUM_BASEURL}/${QUORUM_PKGNAME}"

ARG PATCH_URL="https://github.com/jpmorganchase/quorum/commit/bcf82ca2b9ac4bf78ede873a6230ece497e10052.patch"

RUN mkdir quorum \
 && curl -kL ${TESSERA_URL} -o /usr/local/bin/tessera.jar \
 && curl -kL ${GO_URL} | tar -xz -C /usr/local \
 && curl -kL ${QUORUM_URL} | tar -xz -C quorum --strip-components=1 \
 && curl -kL ${PATCH_URL} -o quorum/fix_428.patch \
 && cd quorum \
 && patch -p1 < fix_428.patch \
 && make all \
 && cp build/bin/geth /usr/local/bin \
 && cp build/bin/bootnode /usr/local/bin \
 && cd .. \
 && rm -rf quorum

FROM ubuntu:16.04

# Install add-apt-repository
RUN apt-get update \
 && apt-get install -y --no-install-recommends software-properties-common \
 && add-apt-repository ppa:ethereum/ethereum \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      curl \
      default-jre \
      libdb-dev \
      libleveldb-dev \
      libsodium-dev \
      zlib1g-dev\
      libtinfo-dev \
      solc \
 && rm -rf /var/lib/apt/lists/*

# Temporary useful tools
#RUN apt-get update && \
#        apt-get install -y iputils-ping net-tools vim

COPY --from=builder \
        /usr/local/bin/tessera.jar \
        /usr/local/bin/geth \
        /usr/local/bin/bootnode \
    /usr/local/bin/

CMD ["/qdata/start-node.sh"]