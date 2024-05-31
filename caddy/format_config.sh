docker run \
  --entrypoint "caddy" \
  --rm -it \
  -v ./Caddyfile:/etc/caddy/Caddyfile:rw \
  caddy:2.7.6-alpine \
  fmt -w "/etc/caddy/Caddyfile"
