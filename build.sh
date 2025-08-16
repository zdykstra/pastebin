#!/bin/bash

maintainer="Zach Dykstra"
container="$(buildah from ghcr.io/void-linux/void-glibc-full:latest)"

buildah config --label author="${maintainer}" "${container}"
mountpoint=$(buildah mount $container)
buildah copy "${container}" pastebin /usr/local/pastebin

mkdir "${mountpoint}/config"

buildah config --workingdir /usr/local/pastebin "${container}"

buildah run "${container}" xbps-install -Syu xbps
buildah run "${container}" xbps-install -Syu
buildah run "${container}" xbps-install -y cpanminus make gcc openssl-devel file

buildah copy "${container}" cpanfile /usr/local/pastebin

buildah run "${container}" cpanm --installdeps --notest .

buildah config --cmd  '[ "/usr/local/pastebin/pastebin.sh" ]' "${container}"

buildah commit --rm "${container}" pastebin
