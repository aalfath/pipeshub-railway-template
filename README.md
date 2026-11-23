[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/pipeshub-1?utm_medium=integration&utm_source=button&utm_campaign=pipeshub)

# PipesHub on Railway

A Railway template for [PipesHub](https://github.com/pipeshub-ai/pipeshub-ai), the open-source context layer for AI agents and enterprise search (permission-aware search and cited answers across Slack, Google Drive, Jira, Confluence and 30+ other sources).

## What it deploys

| Service | Folder | Image (pinned by digest) | Volume |
|---|---|---|---|
| PipesHub (public) | `app/` | `pipeshubai/pipeshub-ai:1.3.0-slim` | `/data/pipeshub` (uploads, model cache) |
| MongoDB | `mongodb/` | `mongo:8.0.38` | `/data/db` |
| Redis | `redis/` | `redis:7.4.12-bookworm` | `/data` |
| Qdrant | `qdrant/` | `qdrant/qdrant:v1.20.2` | `/qdrant/storage` |
| Neo4j | `neo4j/` | `neo4j:5.26.33` (Community, APOC) | `/data` |

Every service builds from this repository, so a merge to `main` reaches everyone who deployed the template as an update they can apply.

## Variables

You enter one value: **`PIPESHUB_ADMIN_EMAIL`**, the email of the first administrator. Everything else is generated or derived:

- `PIPESHUB_ADMIN_PASSWORD`: generated. Read it in the PipesHub service's Variables tab and sign in with it.
- `SECRET_KEY`, `MONGO_PASSWORD`, `REDIS_PASSWORD`, `QDRANT_API_KEY`, `NEO4J_PASSWORD`: generated secrets. Don't change `SECRET_KEY` after the first deploy: it encrypts the stored settings.
- Hosts and URLs come from Railway's private network and the service's public domain.

## How it starts

`app/railway-entrypoint.sh` starts PipesHub on `127.0.0.1:3000` inside the container, creates the first organization and administrator from localhost (upstream lets whoever reaches a fresh instance first claim it), waits until the query and connector services are healthy, and only then opens the public port (`PORT=8080`). The health check path is `/api/v1/health`.

After you sign in, add an AI model (OpenAI, Anthropic, Gemini, Ollama, and others) under Settings, then connect your sources.

## Limits

- The coding sandbox (`run_code` in agents) needs the Docker socket, which Railway doesn't give. It stays off; the rest of the product works.
- PipesHub is memory hungry: on Railway the app used about 5 GB of RAM once started (it also ran with an 8 GB limit). Indexing large sources needs more; upstream recommends 4 vCPU and 16 GB.
- Upstream's anonymous usage telemetry is on by default. Set `TELEMETRY_COLLECTION_FLAG=false` on the PipesHub service to turn it off.

## Updates

Bump the `FROM` tag and digest in the service's `Dockerfile`, add a `CHANGELOG.md` entry (breaking changes first) and merge to `main`.

## Local test

```sh
cat > test/test.env <<'X'
SECRET_KEY=change-me-32-chars-minimum-xxxxxxx
MONGO_PASSWORD=change-me
REDIS_PASSWORD=change-me
QDRANT_API_KEY=change-me
NEO4J_PASSWORD=change-me-8plus
ADMIN_PASSWORD=Change-me-1!
X
docker compose -f test/docker-compose.yml --env-file test/test.env up -d --build
```

License: this wrapper is MIT; PipesHub is Apache-2.0.
