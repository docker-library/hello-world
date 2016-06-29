#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

set -x

docker build -f Dockerfile.build -t hello-world:build .

rm -rf */hello
docker run --rm hello-world:build sh -c 'tar --create */hello' | tar --extract --wildcards '*/hello'

for h in */hello; do
	d="$(dirname "$h")"
	"$h" > /dev/null
	docker build -t hello-world:"test-$d" "$d"
	docker run --rm hello-world:"test-$d"
done
