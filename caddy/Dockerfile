FROM caddy:2.10.2-builder-alpine as builder

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    xcaddy build \
    --with github.com/caddy-dns/cloudflare@6dc1fbb7e925b0da6736780db2e90f4816b79ab7


FROM caddy:2.10.2-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
