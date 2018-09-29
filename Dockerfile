FROM golang:1.11-alpine as builder

WORKDIR /work

RUN apk --update upgrade \
 && apk --no-cache add \
  ca-certificates \
  curl \
  gcc \
  linux-headers \
  make \
  musl-dev \
  tar

ENV PATH $PATH:/usr/local/go/bin

ARG TESSERA_VERSION=0.6
ARG TESSERA_BASEURL="https://github.com/jpmorganchase/tessera/releases/download"
ARG TESSERA_PKGNAME="tessera-${TESSERA_VERSION}/tessera-app-${TESSERA_VERSION}-app.jar"
ARG TESSERA_URL="${TESSERA_BASEURL}/${TESSERA_PKGNAME}"

ARG QUORUM_VERSION=2.1.0
ARG QUORUM_BASEURL="https://github.com/jpmorganchase/quorum/archive"
ARG QUORUM_PKGNAME="v${QUORUM_VERSION}.tar.gz"
ARG QUORUM_URL="${QUORUM_BASEURL}/${QUORUM_PKGNAME}"

ARG SOLC_VERSION=0.4.25
ARG SOLC_BASEURL="https://github.com/ethereum/solidity/releases/download"
ARG SOLC_PKGNAME="v${SOLC_VERSION}/solc-static-linux"
ARG SOLC_URL="${SOLC_BASEURL}/${SOLC_PKGNAME}"

ARG PATCH_URL="https://github.com/jpmorganchase/quorum/commit/bcf82ca2b9ac4bf78ede873a6230ece497e10052.patch"

RUN mkdir quorum \
 && curl -kL ${TESSERA_URL} -o /usr/local/bin/tessera.jar \
 && curl -kL ${QUORUM_URL} | tar -xz -C quorum --strip-components=1 \
 && curl -kL ${PATCH_URL} -o quorum/fix_428.patch \
 && curl -kL ${SOLC_URL} -o /usr/local/bin/solc \
 && cd quorum \
 && patch -p1 < fix_428.patch \
 && make all \
 && cp build/bin/geth /usr/local/bin \
 && cp build/bin/bootnode /usr/local/bin \
 && cd .. \
 && rm -rf quorum


FROM alpine:3.8

# Install add-apt-repository
RUN apk --update upgrade \
 && apk --no-cache add \
  ca-certificates \
  curl \
  openjdk8-jre-base
  



#      curl \
#      default-jre \
#      libdb-dev \
#      libleveldb-dev \
#      libsodium-dev \
#      zlib1g-dev\
#      libtinfo-dev \
#      solc \
# && rm -rf /var/lib/apt/lists/*


COPY --from=builder \
        /usr/local/bin/tessera.jar \
        /usr/local/bin/geth \
        /usr/local/bin/bootnode \
        /usr/local/bin/solc \
    /usr/local/bin/

CMD ["/qdata/start-node.sh"]