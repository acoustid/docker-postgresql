# Docker image with PostgreSQL used by AcoustID

The image is based on the official "postgres" image, but includes a few other tools:

  * [Slony](http://www.slony.info/)
  * [Patroni](https://github.com/zalando/patroni)
  * [wall-e](https://github.com/wal-e/wal-e)
  * [wall-g](https://github.com/wal-g/wal-g)
  * [postgres\_exporter](https://github.com/wrouesnel/postgres_exporter)

And also database extensions:

  * [pg\_acoustid](https://github.com/acoustid/pg_acoustid)
