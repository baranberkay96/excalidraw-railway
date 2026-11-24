#!/bin/sh
# Excalidraw gateway start (Railway).
# 1. Copies the upstream web app and points its collaboration socket at this
#    site (/socket.io/ is proxied to the private Excalidraw Room service) instead
#    of excalidraw.com's public server.
# 2. Sets up the password (Caddy basic auth, bcrypt). No deploy-form value stops
#    the deploy: an unusable password locks the site instead of opening it.
set -u
log() { echo "[railway] $*"; }
warn() { echo "[railway] WARNING: $*" >&2; }

port="${PORT:-8080}"
case "$port" in
'' | *[!0-9]*) warn "PORT='$port' is not a port number; using 8080"; port=8080 ;;
esac
PORT=$port

# --- web app -------------------------------------------------------------
rm -rf /srv/excalidraw
cp -a /srv/excalidraw-dist /srv/excalidraw
patched=0
for f in $(grep -rl 'oss-collab.excalidraw.com' /srv/excalidraw 2>/dev/null); do
	sed -i -e 's#"https://oss-collab\.excalidraw\.com"#window.location.origin#g' \
		-e "s#'https://oss-collab\.excalidraw\.com'#window.location.origin#g" "$f"
	patched=$((patched + 1))
done
left=$(grep -rl 'oss-collab.excalidraw.com' /srv/excalidraw 2>/dev/null | wc -l | tr -d ' ')
if [ "$patched" -gt 0 ] && [ "$left" = "0" ]; then
	log "collaboration socket -> this site (/socket.io/ -> Excalidraw Room); $patched file(s) patched"
else
	warn "could not repoint the collaboration socket ($patched patched, $left left); live collaboration may use excalidraw.com"
fi
# Gzip/brotli copies would still carry the old URL; Caddy compresses on the fly.
find /srv/excalidraw -name '*.gz' -o -name '*.br' | xargs -r rm -f

room=${ROOM_UPSTREAM:-}
if [ -z "$room" ]; then
	warn "ROOM_UPSTREAM is empty; using excalidraw-room.railway.internal:3002"
	room=excalidraw-room.railway.internal:3002
fi
ROOM_UPSTREAM=$room

# --- access --------------------------------------------------------------
case "$(printf '%s' "${EXCALIDRAW_PUBLIC:-false}" | tr 'A-Z' 'a-z')" in
1 | true | yes | on)
	warn "EXCALIDRAW_PUBLIC=true: no password, anyone with the URL can draw and use your room server"
	: > /etc/caddy/auth.caddy
	;;
*)
	user=${EXCALIDRAW_USERNAME:-}
	case "$user" in
	'' | *[!A-Za-z0-9._@-]*)
		warn "EXCALIDRAW_USERNAME='$user' is empty or has characters other than A-Z a-z 0-9 . _ @ -; using 'excalidraw'"
		user=excalidraw
		;;
	esac
	[ "${#user}" -le 64 ] || { warn "EXCALIDRAW_USERNAME is longer than 64 characters; using 'excalidraw'"; user=excalidraw; }
	password=${EXCALIDRAW_PASSWORD:-}
	if [ "${#password}" -lt 12 ] || [ "${#password}" -gt 72 ]; then
		password=$(od -An -N24 -tx1 /dev/urandom | tr -d ' \n')
		warn "EXCALIDRAW_PASSWORD is empty, shorter than 12 or longer than 72 characters."
		warn "The site is LOCKED with a random password nobody knows. Set EXCALIDRAW_PASSWORD"
		warn "(12-72 characters) on the Excalidraw service and redeploy it to sign in."
	fi
	hash=$(caddy hash-password --plaintext "$password") || {
		warn "caddy hash-password failed; locking the site with a random password"
		hash=$(caddy hash-password --plaintext "$(od -An -N24 -tx1 /dev/urandom | tr -d ' \n')")
	}
	unset EXCALIDRAW_PASSWORD password
	printf 'basic_auth {\n\t%s %s\n}\nrequest_header -Authorization\n' "$user" "$hash" > /etc/caddy/auth.caddy
	log "password protection on (user $user)"
	;;
esac

export PORT ROOM_UPSTREAM
log "listening on $PORT; room at $ROOM_UPSTREAM"
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
