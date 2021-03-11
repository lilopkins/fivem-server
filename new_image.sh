#!/bin/bash

VERSION="latest"

while (( "$#" )); do
        case $1 in
                --dry-run)
                        DRY_RUN=1
			shift
                        ;;
		--version)
			VERSION=$2
			shift 2
			;;
                --no-push)
                        NO_PUSH=1
			shift
                        ;;
		--only-if-new)
			IF_NEW=1
			shift
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
--version <version>   Specify an exact version to build an image of.
--dry-run             Don't actually build the image.
--no-push             Build the image but don't push to the registry.
--only-if-new         Only build the image if it's changed since the last build.
--help, -h            Show this help message.
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

if [[ "$VERSION" = "latest" ]]; then
	IS_LATEST_IMAGE=1
fi
LATEST=$(fivem-utility version-server -g ${VERSION})
URL_BASE=$(echo "$LATEST" | awk '{ print $2; }')
URL="${URL_BASE}fx.tar.xz"
VERSION=$(echo "$LATEST" | awk '{ print $1; }')
TAG="$TAG_BASE:$VERSION"

if [ ! $VERSION ]; then
	exit 1
fi

if [[ $IF_NEW -eq 1 ]]; then
	if [[ -f .fivem-version ]]; then
		CURRENT=$(cat .fivem-version)
		if [[ $CURRENT -eq $VERSION ]]; then
			echo "No need to generate a new image."
			exit 0
		fi
	fi
fi

echo "Server version: $VERSION"
echo "Building image '$TAG'..."
if [[ $DRY_RUN -ne 1 ]]; then
	if [[ $IS_LATEST_IMAGE -eq 1 ]]; then
		EXTRA_ARGS="-t $TAG_BASE:latest"
	fi
        docker build \
                --build-arg "PACKAGE_URL=$URL" \
                -t "$TAG" \
		$EXTRA_ARGS \
                .
fi
echo "Finished building."

if [[ $NO_PUSH -ne 1 ]]; then
        echo "Pushing image '$TAG'"
        if [[ $DRY_RUN -ne 1 ]]; then
                docker push "$TAG"
		if [[ $IS_LATEST_IMAGE -eq 1 ]]; then
			docker push "$TAG_BASE:latest"
		fi
        fi
        echo "Pushed."
fi

if [[ $IS_LATEST_IMAGE -eq 1 ]]; then
	echo $VERSION > .fivem-version
fi

echo "Done."

