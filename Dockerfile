# https://github.com/docker-library/postgres/blob/master/18/alpine3.24/Dockerfile
FROM postgres:18.6-alpine

LABEL maintainer="Ivan Muratov <binakot@gmail.com>"

# https://postgis.net/docs/manual-3.7/postgis_installation.html
# Based on https://github.com/postgis/docker-postgis/blob/master/18-3.7/alpine/Dockerfile
ENV POSTGIS_VERSION 3.7.0
ENV POSTGIS_SHA256 306d68a115b88c59d9ffbd134b28fd1b0eccb7b0dabcbb5df2dc0b009d9de848
RUN set -eux \
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
        gdal-dev \
        geos-dev \
        gmp-dev \
        proj-dev \
        proj-util \
        sfcgal-dev \
        \
        # Matches clang/llvm used to build the official postgres alpine image
        $DOCKER_PG_LLVM_DEPS \
        \
        autoconf \
        automake \
        file \
        g++ \
        gcc \
        gettext-dev \
        json-c-dev \
        libtool \
        libxml2-dev \
        make \
        pcre2-dev \
        perl \
        protobuf-c-dev \
    \
    && cd /usr/src/postgis \
    && gettextize \
    && ./autogen.sh \
    && ./configure \
        --enable-lto \
    && make -j"$(nproc)" \
    && make install \
    \
    && apk add --no-cache --virtual .postgis-rundeps \
        gdal \
        geos \
        gmp \
        proj \
        sfcgal \
        json-c \
        libstdc++ \
        pcre2 \
        protobuf-c \
        ca-certificates \
    \
    && cd / \
    && rm -rf /usr/src/postgis \
    && apk del .fetch-deps .build-deps

# https://docs.tigerdata.com/self-hosted/latest/install/installation-source
ENV TIMESCALEDB_VERSION 2.31.0
ENV TIMESCALEDB_SHA256 7a0135283240abb64c87713e3280d70461954028d6426374b7e4e59f7dca6a56
RUN set -eux \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        git \
        openssl \
        openssl-dev \
        tar \
    && apk add --no-cache --virtual .build-deps \
        coreutils \
        dpkg \
        dpkg-dev \
        gcc \
        icu-dev \
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
    && ./bootstrap \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DREGRESS_CHECKS=OFF \
        -DTAP_CHECKS=OFF \
        -DWARNINGS_AS_ERRORS=OFF \
        -DPROJECT_INSTALL_METHOD="docker" \
    && cd ./build && make -j"$(nproc)" install \
    \
    && cd / \
    && rm -rf /usr/src/timescaledb \
    && apk del .fetch-deps .build-deps \
    && sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'timescaledb,\2'/;s/,'/'/" /usr/local/share/postgresql/postgresql.conf.sample

COPY ./init-postgis.sh /docker-entrypoint-initdb.d/1.postgis.sh
COPY ./init-timescaledb.sh /docker-entrypoint-initdb.d/2.timescaledb.sh
COPY ./init-postgres.sh /docker-entrypoint-initdb.d/3.postgres.sh
