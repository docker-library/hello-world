#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

set -x
docker build -f Dockerfile.build -t hello-world:build .
docker run --rm hello-world:build cat hello > hello
chmod +x hello
