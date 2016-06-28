#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

set -x
docker build -f Dockerfile.build -t hello-world:build .
rm -rf */
docker run --rm hello-world:build sh -c 'tar -c */' | tar -x
for d in */; do
	d="${d%/}"
	cp -v Dockerfile.template "$d/Dockerfile"
	"./$d/hello" > /dev/null
	docker build -t hello-world:"test-$d" "$d"
	docker run --rm hello-world:"test-$d"
done
