docker run \
  --entrypoint "caddy" \
  --rm -it \
  -v ./Caddyfile:/etc/caddy/Caddyfile:rw \
  caddy:2.11.7-alpine \
  fmt -w "/etc/caddy/Caddyfile"
