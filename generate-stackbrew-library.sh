#!/bin/bash
set -eu

image="${1:-hello-world}"

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# get the most recent commit which modified any of "$@"
fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

# get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
	local dir="$1"; shift
	(
		cd "$dir"
		fileCommit \
			Dockerfile \
			$(git show HEAD:./Dockerfile | awk '
				toupper($1) == "COPY" {
					for (i = 2; i < NF; i++) {
						print $i
					}
				}
			')
	)
}

cat <<-EOH
# this file is generated via https://github.com/docker-library/hello-world/blob/$(fileCommit "$self")/$self

Maintainers: Tianon Gravi <admwiggin@gmail.com> (@tianon),
             Joseph Ferguson <yosifkit@gmail.com> (@yosifkit)
GitRepo: https://github.com/docker-library/hello-world.git
EOH

commit="$(dirCommit "$image")"

echo
cat <<-EOE
	Tags: latest
	GitCommit: $commit
	Directory: $image
EOE

if [ -d "$image/nanoserver" ]; then
	commit="$(dirCommit "$image/nanoserver")"

	echo
	cat <<-EOE
		Tags: nanoserver
		GitCommit: $commit
		Directory: $image/nanoserver
		Constraints: nanoserver
	EOE
fi
