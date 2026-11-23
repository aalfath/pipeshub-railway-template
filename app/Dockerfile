# PipesHub for Railway: the official all-in-one image, pinned by version and digest.
# To update: bump the tag and digest below, add a CHANGELOG.md entry, merge to main.
FROM pipeshubai/pipeshub-ai:1.3.0-slim@sha256:7c3bac5a294e32809c74bd7564dd72b9061b7072628e0cbc5e1f5050a4248b7b

USER root

# Uploaded files (local storage) live under ~/.local. Point it at the volume so they
# survive redeploys; Railway gives a service one volume, mounted at /data/pipeshub.
RUN rm -r /root/.local && ln -s /data/pipeshub/local /root/.local

COPY --chmod=755 railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
COPY --chmod=644 public-proxy.js /usr/local/lib/railway/public-proxy.js

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["/app/process_monitor.sh"]
