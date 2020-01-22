# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2019-01-22
### Added
- Include [pgBackRest](https://pgbackrest.org/) and [Barman](https://www.pgbarman.org/) in the Docker image.
### Changed
- Upgrade WAL-G from 0.2.9 to 0.2.14
- Changed how WAL-G backups are configured in the included Helm chart.
### Fixed
- Added PGHOST=127.0.0.1 environment variable to the postgresql pod.
### Included packages
- PostgreSQL 11.5
- Patroni 1.6.3
- Stolon 0.14.0
- wal-e 1.1.0
- wal-g 0.2.14
- postgres\_exporter 0.5.1

## [0.1.1] - 2019-01-21
### Fixed
- Fixed default image tag in the included Helm chart.
### Included packages
- PostgreSQL 11.5
- Patroni 1.6.3
- Stolon 0.14.0
- wal-e 1.1.0
- wal-g 0.2.9
- postgres\_exporter 0.5.1

## [0.1.0] - 2019-01-21
### Added
- New versioning scheme.
### Included packages
- PostgreSQL 11.5
- Patroni 1.6.3
- Stolon 0.14.0
- wal-e 1.1.0
- wal-g 0.2.9
- postgres\_exporter 0.5.1

[Unreleased]: https://github.com/acoustid/k8s-postgresql/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/acoustid/k8s-postgresql/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/acoustid/k8s-postgresql/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/acoustid/k8s-postgresql/releases/tag/v0.1.0
