#!/bin/bash
# Railway wrapper for the official PipesHub image.
#  1. Starts PipesHub (upstream entrypoint + process monitor) on 127.0.0.1:3000 inside the container.
#  2. Creates the first organization and administrator from localhost, from
#     PIPESHUB_ADMIN_EMAIL / PIPESHUB_ADMIN_PASSWORD, if none exists yet.
#  3. Only then opens the public port ($PORT), so nobody else can claim a fresh instance.
set -euo pipefail

log() { echo "railway-entrypoint: $*" >&2; }

[ $# -gt 0 ] || set -- /app/process_monitor.sh

PUBLIC_PORT="${PORT:-8080}"
INTERNAL_PORT=3000
if [ "$PUBLIC_PORT" = "$INTERNAL_PORT" ]; then
  log "PORT must not be 3000 (PipesHub uses it inside the container). Set PORT=8080."
  exit 1
fi
DATA_DIR=/data/pipeshub

# --- Fixed settings (upstream's docker-compose defaults). Any of them can be overridden with a service variable.
export NODE_ENV="${NODE_ENV:-production}"
export LOG_LEVEL="${LOG_LEVEL:-info}"
export DATA_STORE="${DATA_STORE:-neo4j}"
export KV_STORE_TYPE="${KV_STORE_TYPE:-redis}"
export MESSAGE_BROKER="${MESSAGE_BROKER:-redis}"
export REPLICA_SET_AVAILABLE="${REPLICA_SET_AVAILABLE:-false}"
export QUERY_BACKEND="${QUERY_BACKEND:-http://localhost:8000}"
export CONNECTOR_BACKEND="${CONNECTOR_BACKEND:-http://localhost:8088}"
export INDEXING_BACKEND="${INDEXING_BACKEND:-http://localhost:8091}"
export EMBEDDING_SERVER_URL="${EMBEDDING_SERVER_URL:-http://localhost:8002}"
export MONGO_DB_NAME="${MONGO_DB_NAME:-es}"
export REDIS_PORT="${REDIS_PORT:-6379}"
export REDIS_DB="${REDIS_DB:-0}"
export REDIS_KV_PREFIX="${REDIS_KV_PREFIX:-pipeshub:kv:}"
export REDIS_TIMEOUT="${REDIS_TIMEOUT:-10000}"
export REDIS_STREAMS_MAXLEN="${REDIS_STREAMS_MAXLEN:-500000}"
export REDIS_URL="${REDIS_URL:-redis://:${REDIS_PASSWORD:-}@${REDIS_HOST:-redis}:${REDIS_PORT}}"
export QDRANT_PORT="${QDRANT_PORT:-6333}"
export QDRANT_GRPC_PORT="${QDRANT_GRPC_PORT:-6334}"
export NEO4J_USERNAME="${NEO4J_USERNAME:-neo4j}"
export NEO4J_DATABASE="${NEO4J_DATABASE:-neo4j}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-2}"
export MCP_SCOPES="${MCP_SCOPES:-openid,profile,email,offline_access,semantic:write,conversation:write,conversation:chat,kb:read,kb:write,kb:upload,team:read,user:read,usergroup:read,config:read,agent:read,agent:execute,connector:read,connector:write,connector:sync,code:read,project:read,project:write,project:delete}"
# Railway's edge is one proxy hop in front of the app (rate limits use the client IP).
export TRUST_PROXY="${TRUST_PROXY:-1}"
# Public URL: derived from the Railway domain unless set.
if [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export FRONTEND_PUBLIC_URL="${FRONTEND_PUBLIC_URL:-https://${RAILWAY_PUBLIC_DOMAIN}}"
  export ALLOWED_ORIGINS="${ALLOWED_ORIGINS:-https://${RAILWAY_PUBLIC_DOMAIN}}"
fi

for v in SECRET_KEY MONGO_URI REDIS_HOST QDRANT_HOST QDRANT_API_KEY NEO4J_URI NEO4J_PASSWORD; do
  if [ -z "${!v:-}" ]; then log "$v is empty; the template sets it. Refusing to start."; exit 1; fi
done

# --- Persistent data: one Railway volume at /data/pipeshub.
#   local/ : uploaded files (~/.local is a symlink to it, see the Dockerfile)
#   hf/    : Hugging Face model cache, seeded from the image so the embedding model
#            downloaded on first use survives redeploys
mkdir -p "$DATA_DIR/local" "$DATA_DIR/hf"
if [ -d /root/.cache/huggingface ]; then
  cp -a -n /root/.cache/huggingface/. "$DATA_DIR/hf/" 2>/dev/null || true
fi
export HF_HOME="${HF_HOME_OVERRIDE:-$DATA_DIR/hf}"
chown -R 1000:1000 "$DATA_DIR/local" "$DATA_DIR/hf" 2>/dev/null || true

# --- Start PipesHub on the internal port. The admin password never reaches it.
child=""; proxy=""
stop() {
  log "stopping"
  [ -n "$proxy" ] && kill -TERM "$proxy" 2>/dev/null || true
  [ -n "$child" ] && kill -TERM "$child" 2>/dev/null || true
  wait 2>/dev/null || true
  exit 143
}
trap stop TERM INT

env -u PIPESHUB_ADMIN_EMAIL -u PIPESHUB_ADMIN_PASSWORD -u PIPESHUB_ADMIN_NAME -u PIPESHUB_ORG_NAME \
  PORT="$INTERNAL_PORT" /usr/local/bin/docker-entrypoint.sh "$@" &
child=$!

alive() { kill -0 "$child" 2>/dev/null; }
die_with_child() { wait "$child"; rc=$?; log "PipesHub exited with code $rc"; exit "$rc"; }
api() { curl -fsS --max-time 10 "http://127.0.0.1:${INTERNAL_PORT}$1"; }

# Wait for the API, then make sure an organization exists.
log "waiting for PipesHub to answer on 127.0.0.1:${INTERNAL_PORT}"
exists=""
while :; do
  alive || die_with_child
  exists="$(api /api/v1/org/exists 2>/dev/null | python3 -c 'import json,sys; print(str(json.load(sys.stdin).get("exists")).lower())' 2>/dev/null || true)"
  [ "$exists" = "true" ] || [ "$exists" = "false" ] && break
  sleep 3
done

if [ "$exists" = "false" ]; then
  if [ -z "${PIPESHUB_ADMIN_EMAIL:-}" ] || [ -z "${PIPESHUB_ADMIN_PASSWORD:-}" ]; then
    log "No organization yet and PIPESHUB_ADMIN_EMAIL or PIPESHUB_ADMIN_PASSWORD is empty. Set both and redeploy."
    kill -TERM "$child"; wait "$child" || true; exit 1
  fi
  log "creating the first organization and administrator (${PIPESHUB_ADMIN_EMAIL})"
  body="$(python3 - <<'PY'
import json, os
print(json.dumps({
  "accountType": "business",
  "registeredName": os.environ.get("PIPESHUB_ORG_NAME") or "PipesHub",
  "contactEmail": os.environ["PIPESHUB_ADMIN_EMAIL"],
  "adminFullName": os.environ.get("PIPESHUB_ADMIN_NAME") or "Admin",
  "password": os.environ["PIPESHUB_ADMIN_PASSWORD"],
  "sendEmail": False,
}))
PY
)"
  code=""
  for i in $(seq 1 20); do
    code="$(printf '%s' "$body" | curl -sS -o /tmp/org.json -w '%{http_code}' --max-time 60 \
      -H 'Content-Type: application/json' --data-binary @- "http://127.0.0.1:${INTERNAL_PORT}/api/v1/org/" || true)"
    case "$code" in 2*) break ;; esac
    log "organization create answered HTTP ${code}: $(head -c 300 /tmp/org.json 2>/dev/null); retrying"
    alive || die_with_child
    sleep 5
  done
  rm /tmp/org.json 2>/dev/null || true
  case "$code" in 2*) log "organization and administrator created" ;; *)
    log "could not create the organization (HTTP ${code})"; kill -TERM "$child"; wait "$child" || true; exit 1 ;;
  esac
fi
unset PIPESHUB_ADMIN_PASSWORD body

# Wait until the query and connector services report healthy (at most READY_WAIT_SECONDS,
# so Railway's health check window is never used up), then open the public port.
log "waiting for the PipesHub services to report healthy"
ready_deadline=$((SECONDS + ${READY_WAIT_SECONDS:-120}))
while [ "$SECONDS" -lt "$ready_deadline" ]; do
  alive || die_with_child
  st="$(api /api/v1/health/services 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin).get("status",""))' 2>/dev/null || true)"
  [ "$st" = "healthy" ] && break
  sleep 5
done

log "ready: opening the public port ${PUBLIC_PORT}"
PUBLIC_PORT="$PUBLIC_PORT" INTERNAL_PORT="$INTERNAL_PORT" node /usr/local/lib/railway/public-proxy.js &
proxy=$!

# Exit (so Railway restarts the container) when either process stops.
while alive && kill -0 "$proxy" 2>/dev/null; do sleep 5; done
alive || die_with_child
log "public proxy stopped; restarting the container"
kill -TERM "$child" 2>/dev/null || true; wait "$child" || true
exit 1
