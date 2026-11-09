# PostgreSQL-PostGIS-TimescaleDB

PostgreSQL + PostGIS + TimescaleDB ready-to-use docker image 🐘🌎📈

Based on [Alpine Linux](https://alpinelinux.org).

Docker image with:
* [PostgreSQL](https://www.postgresql.org/) 
* [PostGIS](http://postgis.net/)
* [TimescaleDB](https://www.timescale.com/)

Current versions of components:
* PostgreSQL: **18.6** ([Source docker image](https://hub.docker.com/_/postgres))
* PostGIS: **3.7.0** ([Release archive](https://github.com/postgis/postgis/releases/tag/3.7.0))
* TimescaleDB: **2.31.0** ([Release archive](https://github.com/timescale/timescaledb/releases/tag/2.31.0))

How to build:

```bash
$ docker build -t binakot/postgresql-postgis-timescaledb .
```

How to run:

```bash
$ docker run -d --name postgres -e POSTGRES_PASSWORD=postgres binakot/postgresql-postgis-timescaledb
```

---

Also you can run app stack with built docker image and pgAdmin4: `docker-compose up`.

PostgreSQL is running on port 5432.

PgAdmin will be available on [localhost:5433](http://localhost:5433) with credentials: `admin@admin.com` / `admin`.

> Note: PostgreSQL 18+ stores data under `/var/lib/postgresql` (major-version subdirectory). The compose volume mounts that path.

---

### Build multi-arch images

To publish a multi-arch image (amd64 + arm64) to Docker Hub:

```bash
$ docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t binakot/postgresql-postgis-timescaledb:latest \
    --push \
    .
```

Check the image architecture:

```bash
$ docker image inspect binakot/postgresql-postgis-timescaledb:arm64 \
    --format '{{.Architecture}}'
```
