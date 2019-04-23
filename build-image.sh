#!/bin/sh

set -ex

PG_VERSION=11.2
PATRONI_VERSION=1.5.6

IMAGE=quay.io/acoustid/postgres-patroni

docker pull $IMAGE:$CI_COMMIT_REF_SLUG
docker build --cache-from=$IMAGE:$CI_COMMIT_REF_SLUG -t $IMAGE:$CI_COMMIT_REF_SLUG .
docker push $IMAGE:$CI_COMMIT_REF_SLUG

docker tag $IMAGE:$CI_COMMIT_REF_SLUG $IMAGE:$PG_VERSION-$PATRONI_VERSION
docker push $IMAGE:latest

docker tag $IMAGE:$CI_COMMIT_REF_SLUG $IMAGE:latest
docker push $IMAGE:latest
