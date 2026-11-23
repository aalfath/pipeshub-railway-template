# Qdrant vector database for PipesHub, pinned by version and digest.
# PipesHub 1.3.0 bundles qdrant-client 1.20.0, so the server stays on 1.20.x.
FROM qdrant/qdrant:v1.20.2@sha256:d277592721d2e3b73f9b797b53cf05e6a5bb2134f6d13fdbda4ca51782afbcac
# Storage and snapshots on the volume at /qdrant/storage; listen on IPv4 and IPv6.
ENV QDRANT__STORAGE__STORAGE_PATH=/qdrant/storage \
    QDRANT__STORAGE__SNAPSHOTS_PATH=/qdrant/storage/snapshots \
    QDRANT__STORAGE__ON_DISK_PAYLOAD=true \
    QDRANT__SERVICE__HOST=:: \
    QDRANT__SERVICE__HTTP_PORT=6333 \
    QDRANT__SERVICE__GRPC_PORT=6334 \
    QDRANT__SERVICE__MAX_REQUEST_SIZE_MB=64 \
    QDRANT__TELEMETRY_DISABLED=true
COPY --chmod=755 start.sh /qdrant/railway-start.sh
CMD ["/qdrant/railway-start.sh"]
