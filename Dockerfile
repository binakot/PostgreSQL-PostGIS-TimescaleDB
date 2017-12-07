FROM postgres:10.1-alpine

MAINTAINER Ivan Muratov, binakot@gmail.com

# https://postgis.net/docs/manual-2.4/postgis_installation.html
ENV POSTGIS_VERSION 2.4.2
RUN set -ex \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        tar \
    && apk add --no-cache --virtual .postgis-deps --repository http://nl.alpinelinux.org/alpine/edge/testing \
        geos \
        gdal \
        proj4 \
    && apk add --no-cache --virtual .build-deps --repository http://nl.alpinelinux.org/alpine/edge/testing \
        postgresql-dev \
        perl \
        file \
        geos-dev \
        libxml2-dev \
        gdal-dev \
        proj4-dev \
        gcc g++ \
        make \
    && cd /tmp \
    && wget http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz -O - | tar -xz \
    && chown root:root -R postgis-${POSTGIS_VERSION} \
    && cd /tmp/postgis-${POSTGIS_VERSION} \
    && ./configure \
    && echo "PERL = /usr/bin/perl" >> extensions/postgis/Makefile \
    && echo "PERL = /usr/bin/perl" >> extensions/postgis_topology/Makefile \
    && make -s \
    && make -s install \
    && cd / \
    \
    && rm -rf /tmp/postgis-${POSTGIS_VERSION} \
    && apk del .fetch-deps .build-deps

# http://docs.timescale.com/latest/getting-started/installation/linux/installation-source
ENV TIMESCALEDB_VERSION 0.7.1
RUN set -ex \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        tar \
    && mkdir -p /build/timescaledb \
    && wget -O /timescaledb.tar.gz https://github.com/timescale/timescaledb/archive/${TIMESCALEDB_VERSION}.tar.gz \
    && tar -C /build/timescaledb --strip-components 1 -zxf /timescaledb.tar.gz \
    && rm -f /timescaledb.tar.gz \
    \
    && apk add --no-cache --virtual .build-deps \
        coreutils \
        dpkg-dev dpkg \
        gcc \
        libc-dev \
        make \
        util-linux-dev \
    \
    && cd /build/timescaledb \
    && ls -la \
    && ./bootstrap \
    && cd ./build \
    && ls -la \
    && make \
    && make install \
    && cd / \
    \
    && apk del .fetch-deps .build-deps \
    && rm -rf /build \
    && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'timescaledb,\2'/;s/,'/'/" /usr/local/share/postgresql/postgresql.conf.sample

COPY ./init-postgres.sh /docker-entrypoint-initdb.d/postgres.sh
COPY ./init-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./init-timescaledb.sh /docker-entrypoint-initdb.d/timescaledb.sh
