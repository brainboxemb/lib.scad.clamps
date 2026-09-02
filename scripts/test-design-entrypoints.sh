#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

run_checked() {
  local label="$1"
  shift

  local log="$TMP_DIR/${label// /-}.log"

  echo "-- $label"

  set +e
  "$@" 2>&1 | tee "$log"
  local status=${PIPESTATUS[0]}
  set -e

  if (( status != 0 )); then
    echo "ERROR: $label failed with exit code $status" >&2
    return "$status"
  fi

  if grep -Eq '(^|[[:space:]])ERROR:' "$log"; then
    echo "ERROR: $label reported an error despite exit code 0" >&2
    return 1
  fi
}

echo "== Design render entrypoints =="

run_checked "OpenSCAD design final" \
  openscad \
  --render \
  -D 'design_view="final"' \
  -o "$TMP_DIR/design-openscad.stl" \
  "$ROOT_DIR/openscad/tube-clamp/tube_clamp_render.scad"

if [[ ! -s "$TMP_DIR/design-openscad.stl" ]]; then
  echo "ERROR: OpenSCAD design entrypoint produced no STL" >&2
  exit 1
fi

run_checked "PythonSCAD design final" \
  xvfb-run -a pythonscad \
  --trust-python \
  --render \
  -D 'design_view="final"' \
  -o "$TMP_DIR/design-pythonscad.stl" \
  "$ROOT_DIR/pythonscad/tube-clamp/tube_clamp_render.py"

if [[ ! -s "$TMP_DIR/design-pythonscad.stl" ]]; then
  echo "ERROR: PythonSCAD design entrypoint produced no STL" >&2
  exit 1
fi

echo
echo "Design render entrypoints passed."
