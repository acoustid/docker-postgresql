#!/usr/bin/env bash

set -eux

flake8 --max-line-length=120 pg_k8s_util
mypy pg_k8s_util
