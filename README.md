# Deploy and Host Excalidraw with Railway

Excalidraw is an open-source virtual whiteboard for sketching hand-drawn-style diagrams, wireframes and flowcharts, with shape libraries, export to PNG/SVG and live collaboration. This template runs the Excalidraw web app behind a password together with your own collaboration server, so live sessions do not go through excalidraw.com's room server.

## About Hosting Excalidraw

The official Excalidraw image is a static web app that connects to excalidraw.com's public collaboration server. This template serves that web app through a small Caddy gateway that points the app's collaboration socket at your own site and forwards `/socket.io/` to a private Excalidraw Room service. The gateway also adds a password, so only people you share it with can open the app or use your room server.

Drawings are saved in each browser (local storage) and can be exported as `.excalidraw`, PNG or SVG files. There is no server-side drawing storage in this template.

## Common Use Cases

- Architecture and system diagrams for engineering teams
- Wireframes and UI sketches during design reviews
- Live whiteboarding in meetings and remote workshops
- Flowcharts and mind maps for planning
- Teaching and explaining ideas with quick hand-drawn visuals

## Dependencies for Excalidraw Hosting

- Excalidraw web app (official image, pinned by digest)
- Excalidraw Room collaboration server (official image, pinned by digest)
- Caddy 2.10 (gateway with password protection)

### Deployment Dependencies

- Excalidraw source: https://github.com/excalidraw/excalidraw
- Collaboration server: https://github.com/excalidraw/excalidraw-room
- Caddy: https://caddyserver.com/docs/

### Implementation Details

| Service | What it does | Public |
|---|---|---|
| Excalidraw | Caddy gateway: password, the web app, `/socket.io/` proxy | yes |
| Excalidraw Room | Socket.IO relay for live collaboration sessions | no |

**First use**

1. Open the Excalidraw URL and sign in with `EXCALIDRAW_USERNAME` (`excalidraw`) and the generated `EXCALIDRAW_PASSWORD` (Excalidraw service, Variables tab).
2. Draw. To collaborate, click Share > Live collaboration and send the link to people who also know the password.

**What stays where.**

- Live collaboration messages go through your Excalidraw Room service only. They are end-to-end encrypted by the app; the key is in the part of the link after `#`, which browsers never send to the server.
- The upstream app still uses excalidraw.com's services for two optional features: "Shareable link" exports and the backup of a live session's scene and images (Firebase). Both are end-to-end encrypted in the browser, but they leave your infrastructure. Use file export instead of shareable links if that matters to you. Self-hosting those storage backends needs a custom build and is not part of this template.
- The room server keeps nothing on disk; when everyone leaves a session, the drawing remains in each participant's browser.

**Access.** Change the password with `EXCALIDRAW_PASSWORD` (12-72 characters) and redeploy the Excalidraw service. A shorter value locks the site instead of opening it. `EXCALIDRAW_PUBLIC=true` removes the password (anyone with the URL can use the app and your room server).

**Custom domain.** Add it to the Excalidraw service; the app connects to the room server through whatever address it was opened with, so nothing else changes.

**Versions.** Images are pinned by digest in `services/excalidraw/Dockerfile` (web app and Caddy) and in the Excalidraw Room service source. Upstream publishes the web app image without version tags; to upgrade, replace the digest with a newer `excalidraw/excalidraw:latest` digest and redeploy.

**Resources.** About 0.05–0.1 GB RAM idle in total (gateway ~0.02 GB, room server ~0.05 GB), well under $1 per month. Runs on the Trial plan.

**License.** Excalidraw and Excalidraw Room are MIT-licensed. This is a community template, not affiliated with Excalidraw.

### Why Deploy Excalidraw on Railway?

Railway runs the web app, your own collaboration server and the password gateway in one project with HTTPS and private networking. Live sessions stay on your server, access is limited to people with the password, and a custom domain is one click away.
