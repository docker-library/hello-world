#!/usr/bin/env bash
set -Eeuo pipefail

image="${1:-hello-world}"

hash="sha256"

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

toBlob() {
    local content="$1"; shift
    local filename="$1"; shift

    output="${ociroot}/$filename"
    echo -n $content > "$output"
    digest="$(cat $output | sha256sum | cut -d " " -f1)"
    ln -s "../../$filename" "$blobs/$digest"
    
    echo $digest
}

rootfs() {
    local os="$1"; shift
    local arch="$1"; shift

    output="${ociroot}/rootfs.tar"
    tar -cf - hello > $output
    digest="$(cat $output | sha256sum | cut -d " " -f1)"
    ln -s "../../rootfs.tar" "$blobs/$digest"
    echo $digest
}

config() {
    local digest="$1"; shift
    local os="$1"; shift
    local arch="$1"; shift
    local timestamp="$1"; shift

    configArch=""

    case "$arch" in
    arm64v8)
        configArch="arm64"
        ;;
    arm32v*)
        configArch="arm"
        ;;
    *)
        configArch="$arch"
        ;;
    esac

    content="$(jq -r -n --arg digest "$hash:$digest" --arg os $os --arg arch $configArch --arg timestamp $timestamp '{
        config: {
            Cmd: [
                "/hello"
            ],
            Env: [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            WorkingDir: "/"
        },
        os: $os,
        architecture: $arch,
        rootfs: {
            diff_ids: [
                $digest
            ],
            type: "layers"
        },
        "created": $timestamp,
    } | tojson')"
    
    toBlob $content "image-config.json"
}

manifest() {
    local configdigest="$1"; shift
    local rootfsdigest="$1"; shift

    configsize="$(wc -c "${ociroot}/image-config.json" | awk '{print $1}')"
    rootfssize="$(wc -c "${ociroot}/rootfs.tar" | awk '{print $1}')"

    content="$(jq -r -n \
        --arg configdigest "$hash:$configdigest" \
        --arg configsize $configsize \
        --arg rootfsdigest "$hash:$rootfsdigest" \
        --arg rootfssize $rootfssize \
        '{
        schemaVersion: 2,
        mediaType: "application/vnd.oci.image.manifest.v1+json",
        config: {
            mediaType: "application/vnd.oci.image.config.v1+json",
            digest: $configdigest,
            size: $configsize | tonumber
        },
        layers: [
            {
                mediaType: "application/vnd.oci.image.layer.v1.tar",
                digest: $rootfsdigest,
                size: $rootfssize | tonumber
            }
        ],
        annotations: {
            "org.opencontainers.image.url": "https://hub.docker.com/_/hello-world",
            "org.opencontainers.image.version": "linux"
        }
    } | tojson')"
    
    toBlob $content "image-manifest.json"
}

indexdescriptor() {
    local manifestdigest="$1"; shift
    local os="$1"; shift
    local arch="$1"; shift

    manifestsize="$(wc -c "${ociroot}/image-manifest.json" | awk '{print $1}')"

    platform=""

    case "$arch" in
    arm64v8)
         platform=$(jq -r -n --arg os $os --arg arch "arm64" --arg variant "v8" '{
            architecture: $arch,
            os: $os,
            variant: $variant
        } | tojson')
        ;;
    arm32v*)
        platform=$(jq -r -n --arg os $os --arg arch "arm" --arg variant "${arch/arm32/}" '{
            architecture: $arch,
            os: $os,
            variant: $variant
        } | tojson')
        ;;
    *)
        platform=$(jq -r -n --arg os $os --arg arch $arch '{
            architecture: $arch,
            os: $os
        } | tojson')
        ;;
    esac

    jq -r -n \
        --arg digest "$hash:$manifestdigest" \
        --arg manifestsize $manifestsize \
        --argjson platform $platform \
        '{
        mediaType: "application/vnd.oci.image.manifest.v1+json",
        digest: $digest,
        size: $manifestsize | tonumber,
        platform: $platform,
        annotations: {
            "org.opencontainers.image.ref.name": "hello-world:linux",
			"io.containerd.image.name": "hello-world:linux"
        }
    } | tojson'
}

created="2025-01-21T23:32:32Z"

arches=( *"/hello" )

for path in "${arches[@]}"; do
    os="linux"
    arch="${path/\/hello/}"

    cd "$arch"

    ociroot="./oci"
    blobs="$ociroot/blobs/$hash"

    rm -rf $ociroot

    mkdir -p $blobs

    rootfs=$(rootfs $os $arch)
    config=$(config $rootfs $os $arch $created)
    manifest=$(manifest $config $rootfs)
    indexdescriptor=$(indexdescriptor $manifest $os $arch)

    jq -r -n --argjson manifests $indexdescriptor '{
        schemaVersion: 2,
        mediaType: "application/vnd.oci.image.index.v1+json",
        manifests: [$manifests]
    }' > "$ociroot/index.json"

    cd -

    # manifests=$(jq -r -n --argjson manifests $manifests --argjson manifest $indexdescriptor '$manifests  | . += [$manifest] | tojson')
done
