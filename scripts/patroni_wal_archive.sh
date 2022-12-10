#!/usr/bin/env bash

set -eu

exec /usr/local/bin/wal-g wal-push "$1"
