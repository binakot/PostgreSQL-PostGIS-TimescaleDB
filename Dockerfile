# https://github.com/docker-library/postgres/blob/master/12/alpine/Dockerfile
FROM postgres:12.5-alpine

MAINTAINER Ivan Muratov, binakot@gmail.com

# https://postgis.net/docs/manual-3.1/postgis_installation.html
ENV POSTGIS_VERSION 3.1.1
ENV POSTGIS_SHA256 28e9cb33d5a762ad2aa72513a05183bf45416ba7de2316ff3ad0da60c4ce56e3
RUN set -ex \
    \
    && apk add --no-cache --virtual .fetch-deps \
        build-base \
        ca-certificates \
        openssl \
        git \
        tar \
    && apk add --no-cache --virtual .build-deps \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        make \
        automake \
        autoconf \
        libtool \
        file \
        gcc \
        g++ \
        perl \
        clang-dev \
        llvm-dev \
        libxml2-dev \
        \
        json-c-dev \
        geos-dev \
        gdal-dev \
        proj-dev \
        protobuf-c-dev \
        postgresql-dev \
    && apk add --no-cache --virtual .postgis-rundeps \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        json-c \
        geos \
        gdal \
        proj \
        protobuf-c \
    \
    && wget -O postgis.tar.gz "https://github.com/postgis/postgis/archive/$POSTGIS_VERSION.tar.gz" \
    && echo "$POSTGIS_SHA256 *postgis.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/postgis \
    && tar \
        --extract \
        --file postgis.tar.gz \
        --directory /usr/src/postgis \
        --strip-components 1 \
    && rm postgis.tar.gz \
    \
    && cd /usr/src/postgis \
    && ./autogen.sh \
    && ./configure \
    && make -s \
    && make -s install \
    && cd / \
    && rm -rf /usr/src/postgis \
    && apk del .fetch-deps .build-deps

# https://docs.timescale.com/v2.0.1/getting-started/installation/ubuntu/installation-source
ENV TIMESCALEDB_VERSION 2.0.1
ENV TIMESCALEDB_SHA256 96e51d5240547f0223c34b91263f6fffca46927710764bf450aa61e9756189bd
RUN set -ex \
    && apk add --no-cache --virtual .fetch-deps \
        build-base \
        ca-certificates \
        openssl \
        git \
        tar \
    && apk add --no-cache --virtual .build-deps \
        make \
        cmake \
        clang \
        clang-dev \
        gcc \
        llvm-dev \
        dpkg \
        dpkg-dev \
        util-linux-dev \
        libc-dev \
        coreutils \
    && apk add --no-cache --virtual .timescaledb-cryptodeps \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        libressl \
        libressl-dev \
        libressl3.1-libcrypto \
        libcrypto1.1 \
    \
    && wget -O timescaledb.tar.gz "https://github.com/timescale/timescaledb/archive/$TIMESCALEDB_VERSION.tar.gz" \
    && echo "$TIMESCALEDB_SHA256 *timescaledb.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/timescaledb \
    && tar \
        --extract \
        --file timescaledb.tar.gz \
        --directory /usr/src/timescaledb \
        --strip-components 1 \
    && rm timescaledb.tar.gz \
    \
    && cd /usr/src/timescaledb \
    && ./bootstrap -DPROJECT_INSTALL_METHOD="docker" -DREGRESS_CHECKS=OFF \
    && cd ./build && make install \
    \
    && cd / \
    && rm -rf /usr/src/timescaledb \
    && apk del .fetch-deps .build-deps \
    && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'timescaledb,\2'/;s/,'/'/" /usr/local/share/postgresql/postgresql.conf.sample

COPY ./init-postgis.sh /docker-entrypoint-initdb.d/1.postgis.sh
COPY ./init-timescaledb.sh /docker-entrypoint-initdb.d/2.timescaledb.sh
COPY ./init-postgres.sh /docker-entrypoint-initdb.d/3.postgres.sh
