#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.local-build"

"$ROOT_DIR/scripts/build-spike.sh" >/dev/null

swiftc \
  -I "$BUILD_DIR" \
  -L "$BUILD_DIR" \
  -lPortiCore \
  -Xlinker -rpath -Xlinker "$BUILD_DIR" \
  "$ROOT_DIR"/Tests/PortiCoreSmokeTests/main.swift \
  -o "$BUILD_DIR/porti-core-smoke-tests"

"$BUILD_DIR/porti-core-smoke-tests"
