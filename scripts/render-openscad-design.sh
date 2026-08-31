#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT_DIR/openscad/tube-clamp/tube-clamp.scad"
OUT_DIR="$ROOT_DIR/openscad/tube-clamp/design/img"
OPENSCAD_BIN="${OPENSCAD_BIN:-openscad}"

mkdir -p "$OUT_DIR"

common_args=(
  --render
  --autocenter
  --viewall
  --projection=o
  --imgsize=1200,900
)

"$OPENSCAD_BIN" "${common_args[@]}" \
  -D 'design_view="01-ring"' \
  -o "$OUT_DIR/01-ring.png" \
  "$SOURCE"

"$OPENSCAD_BIN" "${common_args[@]}" \
  -D 'design_view="02-opening"' \
  -o "$OUT_DIR/02-opening.png" \
  "$SOURCE"

"$OPENSCAD_BIN" "${common_args[@]}" \
  -D 'design_view="final"' \
  -o "$OUT_DIR/03-final.png" \
  "$SOURCE"
