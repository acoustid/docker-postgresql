#!/usr/bin/env bash

set -eu

exec /usr/local/bin/wal-g wal-fetch "$1" "$2"
