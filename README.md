# PostgreSQL-PostGIS-TimescaleDB

**NOT READY YET! WORK IN PROGRESS!**

PostgreSQL + PostGIS + TimescaleDB ready-to-use docker image 🐘🌎📈

Docker image with:
* [PostgreSQL](https://www.postgresql.org/)
* [PostGIS](http://postgis.net/)
* [TimescaleDB](https://www.timescale.com/)

Current versions of components:
* PostgreSQL: **10.1**
* PostGIS: **2.4.2**
* TimescaleDB: **0.7.1**

How to build:

```bash
$ docker build -t binakot/postgres-postgis-timescaledb .
```

How to run:

```bash
$ docker run --name postgres -e POSTGRES_PASSWORD=postgres binakot/postgres-postgis-timescaledb
```
