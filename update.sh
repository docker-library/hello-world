#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

set -x

docker build -f Dockerfile.build -t hello-world:build .

rm -rf */hello */nanoserver/hello.txt
docker run --rm hello-world:build sh -c 'find \( -name hello -or -name hello.txt \) -print0 | xargs -0 tar --create' | tar --extract --verbose

for h in */hello; do
	d="$(dirname "$h")"
	"$h" > /dev/null
	docker build -t hello-world:"test-$d" "$d"
	docker run --rm hello-world:"test-$d"
done
ls -l */nanoserver/hello.txt || :
