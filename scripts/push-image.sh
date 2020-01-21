#!/usr/bin/env bash

set -eu

echo "$QUAY_PASSWORD" | docker login quay.io --username "$QUAY_USERNAME" --password-stdin

set -x

docker push $IMAGE:$VERSION
