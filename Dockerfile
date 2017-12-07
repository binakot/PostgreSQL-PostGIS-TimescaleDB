FROM postgres:10.1-alpine

MAINTAINER Ivan Muratov, binakot@gmail.com

COPY ./init-postgres.sh /docker-entrypoint-initdb.d/postgres.sh
