# Excalidraw Whiteboard with Private Collaboration Server: composer spec

## Listing

| Field | Value |
|---|---|
| Name | **Excalidraw Whiteboard with Private Collaboration Server** |
| Description | Hand-drawn whiteboard with live collab via your own room server, password. (74 chars) |
| Category | Other |
| Icon | `https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/excalidraw.svg` |
| Repo | `baranberkay96/excalidraw-railway`, root `/services/excalidraw` |

Version label: Excalidraw is 0.x and its Docker image has no version tags, so the listing carries no version.

## Base market templates (checked 2026-11-24)

| Code | Active | Notes |
|---|---|---|
| `f7vLxp` | 63 | `excalidraw:latest` + `excalidraw-room` built from GitHub; sets `VITE_APP_WS_SERVER_URL` at runtime, which a prebuilt Vite app ignores, so collaboration still uses excalidraw.com; no password |
| `0K2GLW` | 58 | `excalidraw/excalidraw` only, no password |
| `open-excalidraw` | 2 | third-party fork image `:latest` |

## Services

| Service | Source | Port | Healthcheck | Volume |
|---|---|---|---|---|
| Excalidraw | repo `/services/excalidraw`: Caddy 2.10.2 (digest) + static files copied from `excalidraw/excalidraw@sha256:f7ee194a…` | 8080 public | `/_gateway/health` | — |
| Excalidraw Room | `excalidraw/excalidraw-room:sha-03ff435@sha256:2fe999f9…` | 3002 private | `/` | — |

## Design

1. **Own room server for real.** At start the gateway copies the web app and replaces the baked socket URL `"https://oss-collab.excalidraw.com"` with `window.location.origin` (the only use is `socketIOClient(...)` in `Collab.tsx`), then proxies `/socket.io/*` to the room service. Same-origin, so it works on any custom domain without changes.
2. **Password gateway** (Caddy basic auth, bcrypt; cross-site Origin refused) protects the app and the room server; `EXCALIDRAW_PUBLIC=true` opts out. Short or missing passwords lock the site (8.29), never open it.
3. **Persistence, honestly:** drawings stay in browsers; the upstream build still uses excalidraw.com's Firebase (session backup) and json.excalidraw.com (shareable links), both end-to-end encrypted. Self-hosting those needs a custom build with other backends; not included.

## Improvements over market templates

- Collaboration actually uses the deployer's room server; password protection; pinned digests; healthchecks.

## Resources

Measured on Railway (2026-11-24, idle after a collaboration handshake):

| Service | Idle RAM | CPU idle |
|---|---|---|
| Excalidraw (Caddy gateway) | 0.07 GB | < 0.01 vCPU |
| Excalidraw Room | 0.06 GB | < 0.01 |

Total ≈ 0.13 GB → ≈ $1.3/month. Fits Trial and Free.

## Verification checklist

- [x] Both services SUCCESS; start log `collaboration socket -> this site … 1 file(s) patched`, `password protection on`.
- [x] `/` and `/socket.io/` → 401 without credentials, 200 with them; served JS has 0 `oss-collab` references.
- [x] Socket.IO (polling) through the gateway: `init-room` on connect, `first-in-room` and `room-user-change` after `join-room` — the private room server answers.
- [x] Cross-site Origin → 403.
- [x] `EXCALIDRAW_PASSWORD=short`: deploy SUCCESS, healthcheck 200, old and short passwords both 401 (site locked).

## Open questions

- Browser-level collaboration between two real browsers was checked at protocol level (Socket.IO polling), not with two GUI browsers.
