#!/bin/sh
# MongoDB 8.x refuses to start on Linux 6.19+ hosts unless glibc's rseq is turned off
# (SERVER-121912). Railway hosts run such kernels.
set -eu
export GLIBC_TUNABLES="${GLIBC_TUNABLES:-glibc.pthread.rseq=1}"
export MONGO_INITDB_ROOT_USERNAME="${MONGO_INITDB_ROOT_USERNAME:-admin}"
: "${MONGO_INITDB_ROOT_PASSWORD:?MONGO_INITDB_ROOT_PASSWORD is required}"
exec docker-entrypoint.sh mongod --bind_ip_all --ipv6 --wiredTigerCacheSizeGB "${MONGO_CACHE_GB:-0.5}"
