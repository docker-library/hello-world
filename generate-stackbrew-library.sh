#!/usr/bin/env bash
set -eu

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

commit="$(git log -1 --format='format:%H' HEAD -- '[^.]*/**')"

selfCommit="$(git log -1 --format='format:%H' HEAD -- "$self")"
cat <<-EOH
# this file is generated via https://github.com/docker-library/hello-world/blob/$selfCommit/$self

Maintainers: Tianon Gravi <admwiggin@gmail.com> (@tianon),
             Joseph Ferguson <yosifkit@gmail.com> (@yosifkit)
GitRepo: https://github.com/docker-library/hello-world.git
GitCommit: $commit
EOH

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

arches=( *"/hello" )
arches=( "${arches[@]%"/hello"}" )

echo
cat <<-EOE
	Tags: linux
	SharedTags: latest
	Architectures: $(join ', ' "${arches[@]}")
EOE
for arch in "${arches[@]}"; do
	echo "$arch-Directory: $arch"
done

for winVariant in \
	nanoserver-ltsc2025 \
	nanoserver-ltsc2022 \
; do
	winArches=( *"/$winVariant/hello.txt" )
	winArches=( "${winArches[@]%"/$winVariant/hello.txt"}" )

	if [ "${#winArches[@]}" -gt 0 ]; then
		echo
		cat <<-EOE
			Tags: $winVariant
			SharedTags: nanoserver, latest
			Architectures: $(join ', ' "${winArches[@]/#/windows-}")
		EOE
		for arch in "${winArches[@]}"; do
			echo "windows-$arch-Directory: $arch/$winVariant"
		done
		echo "Constraints: $winVariant"
	fi
done
