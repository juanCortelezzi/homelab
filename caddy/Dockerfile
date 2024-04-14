FROM caddy:2.7.6-builder-alpine as builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare@44030f9306f4815aceed3b042c7f3d2c2b110c97

FROM caddy:2.7.6-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
