# Neo4j Community with APOC (PipesHub's knowledge graph), pinned by version and digest.
FROM neo4j:5.26.33@sha256:51d0314ef86074f519003da8dd4daaa9fff72b8479672b742d7cab7f3064e3ed
# APOC core ships in the image; NEO4J_PLUGINS copies it into place at start (no download).
ENV NEO4J_PLUGINS='["apoc"]' \
    NEO4J_dbms_security_procedures_unrestricted='apoc.*' \
    NEO4J_server_default__listen__address='::' \
    NEO4J_server_memory_heap_initial__size=512m \
    NEO4J_server_memory_heap_max__size=1G \
    NEO4J_server_memory_pagecache_size=512m \
    NEO4J_dbms_cypher_min__replan__interval=30m \
    NEO4J_server_config_strict__validation_enabled=false
COPY --chmod=755 start.sh /startup/railway-start.sh
ENTRYPOINT ["tini", "-g", "--", "/startup/railway-start.sh"]
CMD ["neo4j"]
