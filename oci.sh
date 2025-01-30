#!/usr/bin/env bash
set -Eeuo pipefail

image="${1:-hello-world}"

hash="sha256"

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

ociroot="./oci"
blobs="$ociroot/blobs/$hash"

rm -rf $ociroot

mkdir -p $blobs

toBlob() {
    local content="$1"; shift

    digest="$(echo -n $content | sha256sum | cut -d " " -f1)"
    echo -n $content > "$blobs/$digest"
    echo $digest
}

annotations() {
    local os="$1"; shift
    local arch="$1"; shift
    local timestamp="$1"; shift
    local revision="$1"; shift

    jq -r -n --arg os $os --arg arch $arch --arg timestamp $timestamp --arg revision $revision '{
        "com.docker.official-images.bashbrew.arch": $arch,
        "org.opencontainers.image.base.name": "scratch",
        "org.opencontainers.image.created": $timestamp,
        "org.opencontainers.image.revision": $revision,
        "org.opencontainers.image.source": "https://github.com/docker-library/hello-world.git#\($revision):\($arch)/hello-world",
        "org.opencontainers.image.url": "https://hub.docker.com/_/hello-world",
        "org.opencontainers.image.version": $os
    } | tojson'
}

rootfs() {
    local os="$1"; shift
    local arch="$1"; shift

    path="./$arch/hello-world"
    tar -C $path -cf - hello > tmp.tar
    digest="$(cat tmp.tar | sha256sum | cut -d " " -f1)"
    mv tmp.tar "$blobs/$digest"
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
    
    toBlob $content
}

manifest() {
    local configdigest="$1"; shift
    local rootfsdigest="$1"; shift
    local annotations="$1"; shift

    configsize="$(wc -c "$blobs/$configdigest" | awk '{print $1}')"
    rootfssize="$(wc -c "$blobs/$rootfsdigest" | awk '{print $1}')"

    content="$(jq -r -n \
        --arg configdigest "$hash:$configdigest" \
        --arg configsize $configsize \
        --arg rootfsdigest "$hash:$rootfsdigest" \
        --arg rootfssize $rootfssize \
        --argjson annotations $annotations \
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
        annotations: $annotations
    } | tojson')"
    
    toBlob $content
}

indexdescriptor() {
    local manifestdigest="$1"; shift
    local os="$1"; shift
    local arch="$1"; shift
    local annotations="$1"; shift

    manifestsize="$(wc -c "$blobs/$manifestdigest" | awk '{print $1}')"

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
        --argjson annotations $annotations \
        '{
        mediaType: "application/vnd.oci.image.manifest.v1+json",
        digest: $digest,
        size: $manifestsize | tonumber,
        platform: $platform,
        annotations: $annotations
    } | tojson'
}

created="2025-01-21T23:32:32Z"

arches=( *"/$image/hello" )

manifests="[]"

for path in "${arches[@]}"; do
    os="linux"
    arch="${path/\/hello\-world\/hello/}"

    annotations=$(annotations $os $arch $created "foo")
    rootfs=$(rootfs $os $arch)
    config=$(config $rootfs $os $arch $created)
    manifest=$(manifest $config $rootfs $annotations)
    indexdescriptor=$(indexdescriptor $manifest $os $arch $annotations)

    manifests=$(jq -r -n --argjson manifests $manifests --argjson manifest $indexdescriptor '$manifests  | . += [$manifest] | tojson')
done

# TODO: Windows

jq -r -n --argjson manifests $manifests '{
    schemaVersion: 2,
    mediaType: "application/vnd.oci.image.index.v1+json",
    manifests: $manifests
}' > "$ociroot/index.json"
