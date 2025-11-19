#!/usr/bin/env bash
set -eu

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

generateCommit="$(fileCommit "$self")"
cat <<-EOH
# this file is generated via https://github.com/docker-library/hello-world/blob/$generateCommit/$self

Maintainers: Tianon Gravi <admwiggin@gmail.com> (@tianon),
             Joseph Ferguson <yosifkit@gmail.com> (@yosifkit)
GitRepo: https://github.com/docker-library/hello-world.git
GitCommit: $generateCommit
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
	commit="$(dirCommit "$arch")"
	cat <<-EOE
		$arch-GitCommit: $commit
		$arch-Directory: $arch
	EOE
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
			commit="$(dirCommit "$arch/$winVariant")"
			cat <<-EOE
				windows-$arch-GitCommit: $commit
				windows-$arch-Directory: $arch/$winVariant
			EOE
		done
		cat <<-EOE
			Constraints: $winVariant
		EOE
	fi
done
