#!/bin/sh

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    SELECT version();
    SELECT extname, extversion from pg_extension;
EOSQL
