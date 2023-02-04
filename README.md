# Docker image with PostgreSQL used by AcoustID

The image is based on the official "postgres" image, but includes a few other tools:

  * [Patroni](https://github.com/zalando/patroni)
  * [wal-g](https://github.com/wal-g/wal-g)
  * [pgBackRest](https://pgbackrest.org/)

And also database extensions:

  * [Citus](https://www.citusdata.com/)
  * [pg\_acoustid](https://github.com/acoustid/pg_acoustid)
