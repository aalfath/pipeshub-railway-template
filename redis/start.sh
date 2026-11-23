#!/bin/sh
# Password-protected Redis with append-only persistence on the /data volume,
# listening on IPv4 and IPv6 for Railway's private network.
set -eu
: "${REDIS_PASSWORD:?REDIS_PASSWORD is required}"
exec redis-server --bind "* -::*" --port 6379 --dir /data \
  --appendonly yes --appendfsync everysec --requirepass "$REDIS_PASSWORD"
