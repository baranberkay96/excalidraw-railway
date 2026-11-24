# Excalidraw for Railway: the upstream web app (static files from the official
# image, pinned by digest) served by Caddy with a password, and the collaboration
# socket (/socket.io/) proxied to the private Excalidraw Room service.
ARG EXCALIDRAW_IMAGE=excalidraw/excalidraw@sha256:f7ee194addd607bf831d2af0f0a34463dd4225e426cf35199ef0b12a803398e9
ARG CADDY_IMAGE=caddy:2.10.2-alpine@sha256:4c6e91c6ed0e2fa03efd5b44747b625fec79bc9cd06ac5235a779726618e530d
FROM ${EXCALIDRAW_IMAGE} AS app

FROM ${CADDY_IMAGE}
COPY --from=app /usr/share/nginx/html /srv/excalidraw-dist
COPY Caddyfile /etc/caddy/Caddyfile
COPY --chmod=0755 railway-excalidraw.sh /usr/local/bin/railway-excalidraw.sh
ENTRYPOINT ["/usr/local/bin/railway-excalidraw.sh"]
