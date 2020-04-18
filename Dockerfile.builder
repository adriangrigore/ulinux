FROM alpine:3.11

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
	echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN apk -U add wget \
	build-base autoconf automake coreutils pkgconfig \
	bc elfutils-dev build-base gawk xorriso  bison flex \
	linux-headers perl rsync git argp-standalone diffutils \
	openssl-dev tar xz bash util-linux-dev lzip ncurses-dev

WORKDIR /build

COPY defs.sh /build/defs.sh
COPY functions.sh /build/functions.sh
COPY download.sh /build/download.sh
RUN /bin/sh -c '. download.sh; download_all'

COPY . /build

RUN cd /build/ports/pkg && ./pkg build && ./pkg add && \
	sed -i'' \
	  -e 's|PKG_PORTSDIR=.*|PKG_PORTSDIR=/build/ports|' \
	  -e '/export CC/d'			\
	  -e '/export LD/d'			\
	  -e '/export CFLAGS/d'		\
	  -e '/export MAKEFLAGS/d'  \
	  /etc/pkg.conf

ENTRYPOINT ["./main.sh"]
CMD ["build"]
