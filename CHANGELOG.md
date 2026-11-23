# Changelog

Deployers: read the entry for a version before you apply its update. Breaking changes come first.

## 1.3.0 (2026-11-23)

First release of this template.

- PipesHub `pipeshubai/pipeshub-ai:1.3.0-slim` (upstream v1.3.0, 2026-11-22).
- MongoDB 8.0.38, Redis 7.4.12, Qdrant 1.20.2, Neo4j 5.26.33 Community with APOC, each pinned by digest and on its own volume.
- The first organization and administrator are created from inside the container before the public port opens.
