#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <updates-directory>" >&2
  exit 1
fi

if [[ -z "${SPARKLE_BIN_DIR:-}" ]]; then
  echo "SPARKLE_BIN_DIR must point to the Sparkle distribution's bin directory" >&2
  exit 1
fi

UPDATES_DIR="$1"
GENERATE_APPCAST="$SPARKLE_BIN_DIR/generate_appcast"

if [[ ! -d "$UPDATES_DIR" ]]; then
  echo "updates directory does not exist: $UPDATES_DIR" >&2
  exit 1
fi

if [[ ! -x "$GENERATE_APPCAST" ]]; then
  echo "generate_appcast not found or not executable: $GENERATE_APPCAST" >&2
  exit 1
fi

"$GENERATE_APPCAST" "$UPDATES_DIR"
