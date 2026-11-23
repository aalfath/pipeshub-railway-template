#!/usr/bin/env bash
# Refuse to start without an API key.
set -euo pipefail
if [ -z "${QDRANT__SERVICE__API_KEY:-}" ]; then
  echo "QDRANT__SERVICE__API_KEY is empty; the template generates one." >&2
  exit 1
fi
mkdir -p /qdrant/storage/snapshots
cd /qdrant
exec ./entrypoint.sh "$@"
