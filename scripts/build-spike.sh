#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.local-build"

mkdir -p "$BUILD_DIR"

swiftc \
  -parse-as-library \
  -emit-library \
  -emit-module \
  -module-name PortiCore \
  "$ROOT_DIR"/Sources/PortiCore/*.swift \
  -emit-module-path "$BUILD_DIR/PortiCore.swiftmodule" \
  -o "$BUILD_DIR/libPortiCore.dylib"

swiftc \
  -I "$BUILD_DIR" \
  -L "$BUILD_DIR" \
  -lPortiCore \
  -Xlinker -rpath -Xlinker "$BUILD_DIR" \
  "$ROOT_DIR"/Sources/porti-spike/main.swift \
  -o "$BUILD_DIR/porti-spike"

echo "Built $BUILD_DIR/porti-spike"
