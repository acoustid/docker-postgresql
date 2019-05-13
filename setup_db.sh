#!/usr/bin/env bash

exec psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<EOS
CREATE EXTENSION cube;
CREATE EXTENSION pgcrypto;
CREATE EXTENSION intarray;
CREATE EXTENSION acoustid;
EOS
