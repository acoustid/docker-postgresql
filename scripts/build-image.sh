#!/usr/bin/env bash

set -eux

source versions.sh

docker pull $IMAGE:$VERSION || true

docker build \
    --build-arg PG_VERSION=$PG_VERSION \
    --build-arg PATRONI_VERSION=$PATRONI_VERSION \
    --build-arg WAL_G_VERSION=$WAL_G_VERSION \
    --build-arg POSTGRES_EXPORTER_VERSION=$POSTGRES_EXPORTER_VERSION \
    --cache-from $IMAGE:$VERSION \
    --tag $IMAGE:$VERSION \
    .
