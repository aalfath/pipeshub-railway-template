# MongoDB for PipesHub (upstream uses mongo 8.0), pinned by version and digest.
FROM mongo:8.0.38@sha256:479e85ced54ffb8a40dade1dcde2da2a9ae858515b9415e9cc54bfb8f0575d01
COPY --chmod=755 start.sh /usr/local/bin/railway-mongo-start.sh
CMD ["/usr/local/bin/railway-mongo-start.sh"]
