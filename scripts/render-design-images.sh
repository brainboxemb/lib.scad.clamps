#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

OPENSCAD_SOURCE="$ROOT_DIR/openscad/tube-clamp/tube-clamp.scad"
OPENSCAD_OUT="$ROOT_DIR/openscad/tube-clamp/design/img"

PYTHONSCAD_SOURCE="$ROOT_DIR/pythonscad/tube-clamp/tube-clamp.py"
PYTHONSCAD_OUT="$ROOT_DIR/pythonscad/tube-clamp/design/img"

mkdir -p "$OPENSCAD_OUT" "$PYTHONSCAD_OUT"

common_args=(
  --render
  --autocenter
  --viewall
  --projection=o
  --imgsize=1200,900
)

echo "== OpenSCAD design images =="

openscad "${common_args[@]}" \
  -D 'design_view="01-ring"' \
  -o "$OPENSCAD_OUT/01-ring.png" \
  "$OPENSCAD_SOURCE"

openscad "${common_args[@]}" \
  -D 'design_view="02-opening"' \
  -o "$OPENSCAD_OUT/02-opening.png" \
  "$OPENSCAD_SOURCE"

openscad "${common_args[@]}" \
  -D 'design_view="final"' \
  -o "$OPENSCAD_OUT/03-final.png" \
  "$OPENSCAD_SOURCE"

echo
echo "== PythonSCAD design images =="

DESIGN_VIEW="01-ring" \
xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -o "$PYTHONSCAD_OUT/01-ring.png" \
  "$PYTHONSCAD_SOURCE"

DESIGN_VIEW="02-opening" \
xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -o "$PYTHONSCAD_OUT/02-opening.png" \
  "$PYTHONSCAD_SOURCE"

DESIGN_VIEW="final" \
xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -o "$PYTHONSCAD_OUT/03-final.png" \
  "$PYTHONSCAD_SOURCE"

echo
echo "Design images updated."
