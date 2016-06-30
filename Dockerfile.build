# explicitly use Debian for maximum cross-architecture compatibility
FROM debian:jessie

RUN apt-get update && apt-get install -y --no-install-recommends \
		gcc \
		libc6-dev \
		make \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/hello
COPY . .

RUN set -x \
	&& make clean all test \
	&& ls -l */hello

CMD ["./hello-world/hello"]
