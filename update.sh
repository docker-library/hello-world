#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

set -x

docker build -f Dockerfile.build -t hello-world:build .

find */ \( -name hello -or -name hello.txt \) -delete
docker run --rm hello-world:build sh -c 'find \( -name hello -or -name hello.txt \) -print0 | xargs -0 tar --create' | tar --extract --verbose

find -name hello -type f -exec dirname '{}' ';' | xargs -n1 -i'{}' cp Dockerfile-linux.template '{}/Dockerfile'
find -name hello.txt -type f -exec dirname '{}' ';' | xargs -n1 -i'{}' cp Dockerfile-windows.template '{}/Dockerfile'

for h in */*/nanoserver-*/Dockerfile; do
	nano="$(dirname "$h")"
	nano="$(basename "$nano")"
	nano="${nano#nanoserver-}"
	sed -i 's!FROM .*!FROM mcr.microsoft.com/windows/nanoserver:'"$nano"'!' "$h"
done

for h in amd64/*/hello; do
	d="$(dirname "$h")"
	b="$(basename "$d")"
	"$h" > /dev/null
	docker build -t hello-world:"test-$b" "$d"
	docker run --rm hello-world:"test-$b"
done

ls -lh */*/{hello,nanoserver*/hello.txt} || :
