# https://github.com/docker-library/postgres/blob/master/10/alpine/Dockerfile
FROM postgres:10.1-alpine

MAINTAINER Ivan Muratov, binakot@gmail.com

# https://postgis.net/docs/manual-2.4/postgis_installation.html
# https://github.com/appropriate/docker-postgis/blob/master/10-2.4/alpine/Dockerfile
ENV POSTGIS_VERSION 2.4.2
ENV POSTGIS_SHA256 1632baa8175c11f8c7e6a49d23b66d67c196d50c453244817b58e4b31d8a01b7
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
ENV TIMESCALEDB_VERSION 0.7.1
ENV TIMESCALEDB_SHA256 f1aa897d733dcf04a131ac82ba977c39f0a1373b07fb85a377140ef63d054509
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

COPY ./init-postgres.sh /docker-entrypoint-initdb.d/postgres.sh
COPY ./init-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./init-timescaledb.sh /docker-entrypoint-initdb.d/timescaledb.sh
