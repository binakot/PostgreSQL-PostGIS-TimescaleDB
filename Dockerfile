# https://github.com/docker-library/postgres/blob/master/10/alpine/Dockerfile
FROM postgres:10.5-alpine

MAINTAINER Ivan Muratov, binakot@gmail.com

# https://postgis.net/docs/manual-2.4/postgis_installation.html
ENV POSTGIS_VERSION 2.4.5
ENV POSTGIS_SHA256 14815a11ff1fbeaa4a0cb942a9509c35e850395b0694f6fc6ebe6276ef13fccf
RUN set -ex \
    \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        tar \
    && apk add --no-cache --virtual .crypto-rundeps \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        libressl2.7-libcrypto \
    && apk add --no-cache --virtual .postgis-deps \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        geos \
        gdal \        
        proj4 \
        protobuf-c \
    && apk add --no-cache --virtual .build-deps \
        --repository http://nl.alpinelinux.org/alpine/edge/testing \
        postgresql-dev \
        perl \
        file \
        geos-dev \
        libxml2-dev \
        gdal-dev \
        proj4-dev \
        protobuf-c-dev \
        json-c-dev \
        gcc \
        g++ \
        make \
        autoconf \
        automake \        
        libtool \
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
    && apk add --no-cache --virtual .postgis-rundeps \
        json-c \
    && cd / \
    && rm -rf /usr/src/postgis \
    && apk del .fetch-deps .build-deps

# http://docs.timescale.com/latest/getting-started/installation/linux/installation-source
ENV TIMESCALEDB_VERSION 0.12.1
ENV TIMESCALEDB_SHA256 40667715d0cdcd3eb57a3dd5a23a6c0e85e394e9096eb100b913e8c5489719cd
RUN set -ex \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        openssl-dev \
        tar \
    && apk add --no-cache --virtual .build-deps \
        coreutils \
        dpkg \
        dpkg-dev \
        gcc \
        libc-dev \
        make \
        cmake \
        util-linux-dev \
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
    && ./bootstrap -DPROJECT_INSTALL_METHOD="docker" \
    && cd ./build && make install \
    \
    && cd / \
    && rm -rf /usr/src/timescaledb \
    && apk del .fetch-deps .build-deps \    
    && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'timescaledb,\2'/;s/,'/'/" /usr/local/share/postgresql/postgresql.conf.sample

COPY ./init-postgis.sh /docker-entrypoint-initdb.d/1.postgis.sh
COPY ./init-timescaledb.sh /docker-entrypoint-initdb.d/2.timescaledb.sh
COPY ./init-postgres.sh /docker-entrypoint-initdb.d/3.postgres.sh
