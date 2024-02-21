FROM caddy:2.7.6-builder-alpine as builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare@2fa0c8ac916ab13ee14c836e59fec9d85857e429

FROM caddy:2.7.6-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
