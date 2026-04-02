#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <updates-directory>" >&2
  exit 1
fi

UPDATES_DIR="$1"
SPARKLE_BIN_DIR="${SPARKLE_BIN_DIR:-$ROOT_DIR/.build/artifacts/sparkle/Sparkle/bin}"
GENERATE_APPCAST="$SPARKLE_BIN_DIR/generate_appcast"
APPCAST_ARGS=()

if [[ -n "${APPCAST_DOWNLOAD_URL_PREFIX:-}" ]]; then
  APPCAST_ARGS+=(--download-url-prefix "$APPCAST_DOWNLOAD_URL_PREFIX")
fi

if [[ -n "${APPCAST_LINK:-}" ]]; then
  APPCAST_ARGS+=(--link "$APPCAST_LINK")
fi

if [[ ! -d "$UPDATES_DIR" ]]; then
  echo "updates directory does not exist: $UPDATES_DIR" >&2
  exit 1
fi

if [[ ! -x "$GENERATE_APPCAST" ]]; then
  echo "generate_appcast not found or not executable: $GENERATE_APPCAST" >&2
  echo "build the package once so SwiftPM fetches Sparkle, or set SPARKLE_BIN_DIR explicitly" >&2
  exit 1
fi

"$GENERATE_APPCAST" "${APPCAST_ARGS[@]}" "$UPDATES_DIR"
