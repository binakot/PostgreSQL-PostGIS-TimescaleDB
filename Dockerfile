# https://github.com/docker-library/postgres/blob/master/11/alpine/Dockerfile
FROM postgres:11.1-alpine

MAINTAINER Ivan Muratov, binakot@gmail.com

# https://postgis.net/docs/manual-2.5/postgis_installation.html
ENV POSTGIS_VERSION 2.5.1
ENV POSTGIS_SHA256 d380e9ec0aeee87c5d976b9111ea11199ba875f2cd496c49b4141db29cee9557
RUN set -ex \
    \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        tar \
    && apk add --no-cache --virtual .build-deps \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        make \
        automake \
        autoconf \
        libtool \
        gcc \
        g++ \
        file \
        perl \
        json-c-dev \
        libxml2-dev \
        \
        geos-dev \
        gdal-dev \
        proj4-dev \
        protobuf-c-dev \
        postgresql-dev \
    && apk add --no-cache --virtual .postgis-deps \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        geos \
        gdal \
        proj4 \
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
    && apk add --no-cache --virtual .postgis-rundeps \
        json-c \
    && cd / \
    && rm -rf /usr/src/postgis \
    && apk del .fetch-deps .build-deps

# http://docs.timescale.com/latest/getting-started/installation/linux/installation-source
ENV TIMESCALEDB_VERSION 1.1.1
ENV TIMESCALEDB_SHA256 c2f0f745f9ab52bf7fedd24e129efde5f39a0f27a8f41e1568aab98cd21d5a68
RUN set -ex \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        openssl-dev \
        tar \
    && apk add --no-cache --virtual .build-deps \
        make \
        cmake \
        gcc \
        dpkg \
        dpkg-dev \
        util-linux-dev \
        libc-dev \
        coreutils \
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
