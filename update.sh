#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

set -x

docker build -f Dockerfile.build -t hello-world:build .

rm -rf */hello */nanoserver/hello.txt
docker run --rm hello-world:build sh -c 'find \( -name hello -or -name hello.txt \) -print0 | xargs -0 tar --create' | tar --extract --verbose

for h in amd64/*/hello; do
	d="$(dirname "$h")"
	b="$(basename "$d")"
	"$h" > /dev/null
	docker build -t hello-world:"test-$b" "$d"
	docker run --rm hello-world:"test-$b"
done
ls -lh */*/{hello,nanoserver/hello.txt} || :
