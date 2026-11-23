# Changelog

Deployers: read the entry for a version before you apply its update. Breaking changes come first.

## 1.3.0-2 (2026-11-23)

**Breaking for MongoDB data:** MongoDB moves from 8.0.38 to 7.0.48. MongoDB 8.0 exits at startup on Linux kernels 6.19 through 7.0.13 ("MongoDB cannot start: Linux kernel versions 6.19.0 through 7.0.13 have a known incompatibility", SERVER-121912 / SERVER-125742), and some Railway hosts run those kernels, so a deploy could crash depending on where it landed. MongoDB 7.0 runs on every kernel. MongoDB 7.0 can't open data files written by 8.0: if your MongoDB service already started with 8.0 and holds data, don't apply this update.

- No change to PipesHub (still 1.3.0), Redis, Qdrant or Neo4j.

## 1.3.0-1 (2026-11-23)

No change to the services: adds the Deploy on Railway button to the README, linking to the published template `pipeshub-1`.

## 1.3.0 (2026-11-23)

First release of this template.

- PipesHub `pipeshubai/pipeshub-ai:1.3.0-slim` (upstream v1.3.0, 2026-11-22).
- MongoDB 8.0.38, Redis 7.4.12, Qdrant 1.20.2, Neo4j 5.26.33 Community with APOC, each pinned by digest and on its own volume.
- The first organization and administrator are created from inside the container before the public port opens.
