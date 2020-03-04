#!/bin/bash

for i in "$@"; do
        case $i in
                --dry-run)
                        DRY_RUN=1
                        ;;
                --no-push)
                        NO_PUSH=1
                        ;;
                --help|-h)
                        cat <<END
FiveM Server Docker Image Autobuild

Prerequesites:
This script requires that the following are available:
- cat
- awk
- fivem-utility
- docker

Usage:
$0 [OPTIONS...]

Options:
--dry-run       Don't actually build the image.
--no-push       Build the image but don't push to the registry.
--help, -h      Show this help message.
END
                        exit 0
                        ;;
        esac
done

if [[ $DRY_RUN -eq 1 ]]; then
        echo "----- DRY RUN ONLY! -----" >&2
else
        if ! [ $(id -u) -eq 0 ]; then
                echo "This script needs to be run with sudo (or with --dry-run)." >&2
                exit 1
        fi
fi

TAG_BASE="registry.gitlab.com/meridiangrp/fivem-server"
VERSION_REGEX="https:\\/\\/runtime.fivem.net\\/artifacts\\/fivem\\/build_proot_linux\\/master\\/(\\d+)-[\\da-z]+\\/"

LATEST=$(fivem-utility version-server -g latest)
URL_BASE=$(echo "$LATEST" | awk '{ print $2; }')
URL="${URL_BASE}fx.tar.xz"
VERSION=$(echo "$LATEST" | awk '{ print $1; }')
TAG="$TAG_BASE:$VERSION"

echo "Server version: $VERSION"
echo "Building image '$TAG'..."
if [[ $DRY_RUN -ne 1 ]]; then
        docker build \
                --build-arg "PACKAGE_URL=$URL" \
                -t "$TAG" \
                .
fi
echo "Finished building."

if [[ $NO_PUSH -ne 1 ]]; then
        echo "Pushing image '$TAG'"
        if [[ $DRY_RUN -ne 1 ]]; then
                docker push "$TAG"
        fi
        echo "Pushed."
fi
echo "Done."
