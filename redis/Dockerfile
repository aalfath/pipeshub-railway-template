# Redis for PipesHub (key-value store and Redis Streams message broker), pinned by version and digest.
FROM redis:7.4.12-bookworm@sha256:2e3eb11462c4e3759e6972678dd051d150ff54b1e60714b3c33b701260172a90
COPY --chmod=755 start.sh /usr/local/bin/railway-redis-start.sh
CMD ["/usr/local/bin/railway-redis-start.sh"]
