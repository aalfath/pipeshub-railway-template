#!/bin/sh
# MongoDB 7.0 for PipesHub, reachable over Railway's private network (IPv6).
set -eu
echo "railway-mongo-start: kernel $(uname -r)"
export MONGO_INITDB_ROOT_USERNAME="${MONGO_INITDB_ROOT_USERNAME:-admin}"
: "${MONGO_INITDB_ROOT_PASSWORD:?MONGO_INITDB_ROOT_PASSWORD is required}"
exec docker-entrypoint.sh mongod --bind_ip_all --ipv6 --wiredTigerCacheSizeGB "${MONGO_CACHE_GB:-0.5}"
