# Notice

This repository is a Railway template package for Excalidraw. It contains a Dockerfile, a Caddyfile and a start script written for this template (MIT-licensed); it does not contain Excalidraw source code. The gateway design (Caddy basic auth, cross-site check, health route) follows this project's own Bytebot template.

| Component | License | Used as |
|---|---|---|
| Excalidraw web app | MIT (Copyright (c) 2020 Excalidraw) | Static files copied from the official image `excalidraw/excalidraw@sha256:f7ee194a…` (pushed 2026-05-06); at start the collaboration server URL in the built JavaScript is replaced with the page's own origin |
| Excalidraw Room | MIT (Copyright (c) 2020 Excalidraw) | Official image `excalidraw/excalidraw-room:sha-03ff435@sha256:2fe999f9…`, unmodified |
| Caddy 2.10.2 | Apache License 2.0 | Official image `caddy:2.10.2-alpine@sha256:4c6e91c6…` |

## Upstream files checked

- excalidraw/excalidraw at v0.18.1: `Dockerfile`, `.env.production`, `excalidraw-app/package.json`, `excalidraw-app/collab/Collab.tsx`
- excalidraw/excalidraw-room (master): `Dockerfile`, `src/index.ts`

Excalidraw is a trademark of its owners. This community template is not affiliated with or endorsed by Excalidraw.
