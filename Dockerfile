# https://github.com/docker-library/postgres/blob/master/10/alpine/Dockerfile
FROM postgres:10.3-alpine

MAINTAINER Ivan Muratov, binakot@gmail.com

# https://postgis.net/docs/manual-2.4/postgis_installation.html
# https://github.com/appropriate/docker-postgis/blob/master/10-2.4/alpine/Dockerfile
ENV POSTGIS_VERSION 2.4.3
ENV POSTGIS_SHA256 b9754c7b9cbc30190177ec34b570717b2b9b88ed271d18e3af68eca3632d1d95
RUN set -ex \
    \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        tar \
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
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        g++ \
        json-c-dev \
        libtool \
        libxml2-dev \
        make \
        perl \
    \
    && apk add --no-cache --virtual .build-deps-testing \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        gdal-dev \
        geos-dev \
        proj4-dev \
    && cd /usr/src/postgis \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && apk add --no-cache --virtual .postgis-rundeps \
        json-c \
    && apk add --no-cache --virtual .postgis-rundeps-testing \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        geos \
        gdal \
        proj4 \
    && cd / \
    && rm -rf /usr/src/postgis \
    && apk del .fetch-deps .build-deps .build-deps-testing

# http://docs.timescale.com/latest/getting-started/installation/linux/installation-source
# https://github.com/timescale/timescaledb-docker/blob/master/Dockerfile
ENV TIMESCALEDB_VERSION 0.9.0
ENV TIMESCALEDB_SHA256 f8f8a39001b63ffb705a94f9ebaf4e3ded6964bdcd8ca117c735bbbaf4ba5ac4
RUN set -ex \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        tar \
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
    && apk add --no-cache --virtual .build-deps \
        coreutils \
        dpkg-dev dpkg \
        gcc \
        libc-dev \
        make \        
        util-linux-dev \
        cmake \
    \
    && cd /usr/src/timescaledb \
    && ./bootstrap \    
    && cd ./build \
    && make \
    && make install \
    \
    && cd / \
    && rm -rf /usr/src/timescaledb \
    && apk del .fetch-deps .build-deps \    
    && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'timescaledb,\2'/;s/,'/'/" /usr/local/share/postgresql/postgresql.conf.sample

COPY ./init-postgis.sh /docker-entrypoint-initdb.d/1.postgis.sh
COPY ./init-timescaledb.sh /docker-entrypoint-initdb.d/2.timescaledb.sh
COPY ./init-postgres.sh /docker-entrypoint-initdb.d/3.postgres.sh
