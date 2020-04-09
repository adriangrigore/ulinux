FROM alpine:3.11 AS build

RUN apk add --no-cache -U jq curl ca-certificates

WORKDIR /src

COPY . .

RUN .dockerfiles/build_rootfs.sh

FROM scratch

COPY --from=build /rootfs /

CMD ["/bin/sh"]
