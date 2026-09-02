#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

OPENSCAD_SOURCE="$ROOT_DIR/openscad/tube-clamp/design/render.scad"
OPENSCAD_OUT="$ROOT_DIR/openscad/tube-clamp/design/img"

PYTHONSCAD_SOURCE="$ROOT_DIR/pythonscad/tube-clamp/design/render.py"
PYTHONSCAD_LIB="$ROOT_DIR/pythonscad/tube-clamp"
PYTHONSCAD_OUT="$ROOT_DIR/pythonscad/tube-clamp/design/img"

mkdir -p "$OPENSCAD_OUT" "$PYTHONSCAD_OUT"

common_args=(
  --render
  --autocenter
  --viewall
  --projection=o
  --imgsize=1200,900
)

run_checked() {
  local label="$1"
  shift

  local log
  log="$(mktemp)"

  echo "-- $label"

  set +e
  "$@" 2>&1 | tee "$log"
  local status=${PIPESTATUS[0]}
  set -e

  if (( status != 0 )); then
    echo "ERROR: $label failed with exit code $status" >&2
    rm -f "$log"
    return "$status"
  fi

  if grep -Eq '(^|[[:space:]])ERROR:' "$log"; then
    echo "ERROR: $label reported an error even though the process returned exit code 0" >&2
    rm -f "$log"
    return 1
  fi

  rm -f "$log"
}

echo "== OpenSCAD design images =="

run_checked "OpenSCAD 01-ring" \
  openscad "${common_args[@]}" \
  -D 'design_view="01-ring"' \
  -o "$OPENSCAD_OUT/01-ring.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 02-opening" \
  openscad "${common_args[@]}" \
  -D 'design_view="02-opening"' \
  -o "$OPENSCAD_OUT/02-opening.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 03-final" \
  openscad "${common_args[@]}" \
  -D 'design_view="final"' \
  -o "$OPENSCAD_OUT/03-final.png" \
  "$OPENSCAD_SOURCE"

echo
echo "== PythonSCAD design images =="

run_checked "PythonSCAD 01-ring" \
  env PYTHONPATH="$PYTHONSCAD_LIB${PYTHONPATH:+:$PYTHONPATH}" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="01-ring"' \
  -o "$PYTHONSCAD_OUT/01-ring.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 02-opening" \
  env PYTHONPATH="$PYTHONSCAD_LIB${PYTHONPATH:+:$PYTHONPATH}" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="02-opening"' \
  -o "$PYTHONSCAD_OUT/02-opening.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 03-final" \
  env PYTHONPATH="$PYTHONSCAD_LIB${PYTHONPATH:+:$PYTHONPATH}" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="final"' \
  -o "$PYTHONSCAD_OUT/03-final.png" \
  "$PYTHONSCAD_SOURCE"

echo
echo "Design images updated."
