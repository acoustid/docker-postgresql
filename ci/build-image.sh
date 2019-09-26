#!/usr/bin/env bash

set -eux

VERSION=$(echo "$GITHUB_REF" | cut -d/ -f3-)

source versions.sh

docker build \
    --build-arg PG_VERSION=$PG_VERSION \
    --build-arg STOLON_VERSION=$STOLON_VERSION \
    --tag quay.io/acoustid/postgresql:$VERSION \
    .
