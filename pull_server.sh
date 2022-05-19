#!/bin/bash

LATEST=$(fivem-utility version-server -g latest)
URL_BASE=$(echo "$LATEST" | awk '{ print $2; }')
URL="${URL_BASE}fx.tar.xz"
VERSION=$(echo "$LATEST" | awk '{ print $1; }')

echo "Server version: $VERSION"
curl -Lo fx.tar.xz "$URL"
