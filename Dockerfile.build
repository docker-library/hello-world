# explicitly use Debian for maximum cross-architecture compatibility
FROM debian:jessie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
		gcc \
		libc6-dev \
		make \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/hello
COPY . .

RUN set -ex; \
	make clean all test; \
	find \( -name 'hello' -or -name 'hello.txt' \) -exec ls -l '{}' +

CMD ["./hello-world/hello"]
