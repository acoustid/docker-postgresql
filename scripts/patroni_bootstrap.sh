#!/usr/bin/env bash

set -eu

DATA_DIR=

while getopts ":-:" optchar; do
    [[ "${optchar}" == "-" ]] || continue
    case "${OPTARG}" in
        datadir=* )
            DATA_DIR=${OPTARG#*=}
            ;;
        connstring=* )
            CONNSTR="${OPTARG#*=}"
            ;;
        retries=* )
            RETRIES=${OPTARG#*=}
            ;;
        threshold_backup_size_percentage=*|threshold-backup-size-percentage=* )
            THRESHOLD_PERCENTAGE=${OPTARG#*=}
            ;;
        threshold_megabytes=*|threshold-megabytes=* )
            THRESHOLD_MEGABYTES=${OPTARG#*=}
            ;;
        no_master=*|no-master=* )
            NO_MASTER=${OPTARG#*=}
            ;;
    esac
done

[[ -z $DATA_DIR ]] && exit 1

exec /usr/local/bin/wal-g backup-fetch $DATA_DIR LATEST
