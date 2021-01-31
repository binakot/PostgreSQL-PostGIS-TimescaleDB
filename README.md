# PostgreSQL-PostGIS-TimescaleDB

PostgreSQL + PostGIS + TimescaleDB ready-to-use docker image 🐘🌎📈

Based on [Alpine Linux](https://alpinelinux.org).

Docker image with:
* [PostgreSQL](https://www.postgresql.org/) 
* [PostGIS](http://postgis.net/)
* [TimescaleDB](https://www.timescale.com/)

Current versions of components:
* PostgreSQL: **12.5** ([Source docker image](https://store.docker.com/images/postgres))
* PostGIS: **3.1.1** ([Release archive](https://github.com/postgis/postgis/releases/tag/3.1.1))
* TimescaleDB: **2.0.1** ([Release archive](https://github.com/timescale/timescaledb/releases/tag/2.0.1))

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
