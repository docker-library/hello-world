# explicitly use Debian for maximum cross-architecture compatibility
FROM debian:buster-slim

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		gnupg dirmngr \
		wget \
		\
		gcc \
		libc6-dev \
		make \
		\
		libc6-dev-arm64-cross \
		libc6-dev-armel-cross \
		libc6-dev-armhf-cross \
		libc6-dev-i386-cross \
		libc6-dev-ppc64el-cross \
		libc6-dev-s390x-cross \
		\
		gcc-aarch64-linux-gnu \
		gcc-arm-linux-gnueabi \
		gcc-arm-linux-gnueabihf \
		gcc-i686-linux-gnu \
		gcc-powerpc64le-linux-gnu \
		gcc-s390x-linux-gnu \
		\
		file \
	; \
	rm -rf /var/lib/apt/lists/*

# https://www.musl-libc.org/download.html
ENV MUSL_VERSION 1.1.24
RUN set -eux; \
	wget -O musl.tgz.asc "https://www.musl-libc.org/releases/musl-$MUSL_VERSION.tar.gz.asc"; \
	wget -O musl.tgz "https://www.musl-libc.org/releases/musl-$MUSL_VERSION.tar.gz"; \
	\
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys '836489290BB6B70F99FFDA0556BCDB593020450F'; \
	gpg --batch --verify musl.tgz.asc musl.tgz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" musl.tgz.asc; \
	\
	mkdir /usr/local/src/musl; \
	tar --extract --file musl.tgz --directory /usr/local/src/musl --strip-components 1; \
	rm musl.tgz

WORKDIR /usr/src/hello
COPY . .

RUN set -ex; \
	make clean all test \
		TARGET_ARCH='amd64' \
		CROSS_COMPILE='x86_64-linux-gnu-'

RUN set -ex; \
	make clean all \
		TARGET_ARCH='arm32v5' \
		CROSS_COMPILE='arm-linux-gnueabi-'

RUN set -ex; \
	make clean all \
		TARGET_ARCH='arm32v7' \
		CROSS_COMPILE='arm-linux-gnueabihf-'

RUN set -ex; \
	make clean all \
		TARGET_ARCH='arm64v8' \
		CROSS_COMPILE='aarch64-linux-gnu-'

RUN set -ex; \
	make clean all test \
		TARGET_ARCH='i386' \
		CROSS_COMPILE='i686-linux-gnu-'

RUN set -ex; \
	make clean all \
		TARGET_ARCH='ppc64le' \
		CROSS_COMPILE='powerpc64le-linux-gnu-' \
		CFLAGS+='-mlong-double-64'

RUN set -ex; \
	make clean all \
		TARGET_ARCH='s390x' \
		CROSS_COMPILE='s390x-linux-gnu-'

RUN find \( -name 'hello' -or -name 'hello.txt' \) -exec file '{}' + -exec ls -lh '{}' +

CMD ["./amd64/hello-world/hello"]
