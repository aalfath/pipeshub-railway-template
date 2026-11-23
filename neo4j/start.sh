#!/bin/bash
# Sets NEO4J_AUTH from NEO4J_PASSWORD (the template generates it), then runs the official entrypoint.
set -euo pipefail
: "${NEO4J_PASSWORD:?NEO4J_PASSWORD is required}"
export NEO4J_AUTH="neo4j/${NEO4J_PASSWORD}"
exec /startup/docker-entrypoint.sh "$@"
