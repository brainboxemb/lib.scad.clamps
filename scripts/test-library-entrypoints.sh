#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

OPENSCAD_OUT="$ROOT_DIR/openscad/tube-clamp/tube_clamp.png"
PYTHONSCAD_OUT="$ROOT_DIR/pythonscad/tube-clamp/tube_clamp.png"

mkdir -p \
  "$(dirname "$OPENSCAD_OUT")" \
  "$(dirname "$PYTHONSCAD_OUT")"

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
    echo "ERROR: $label reported an error despite exit code 0" >&2
    rm -f "$log"
    return 1
  fi

  rm -f "$log"
}

echo "== Standalone library/show entrypoints =="

run_checked "OpenSCAD tube-clamp" \
  openscad --enable=object-function \
  --render \
  --autocenter \
  --viewall \
  --projection=o \
  --imgsize=1200,900 \
  -o "$OPENSCAD_OUT" \
  "$ROOT_DIR/openscad/tube-clamp/tube_clamp.scad"

if [[ ! -s "$OPENSCAD_OUT" ]]; then
  echo "ERROR: OpenSCAD tube-clamp produced no verification PNG" >&2
  exit 1
fi

run_checked "PythonSCAD tube-clamp" \
  xvfb-run -a pythonscad \
  --trust-python \
  --render \
  --autocenter \
  --viewall \
  --projection=o \
  --imgsize=1200,900 \
  -o "$PYTHONSCAD_OUT" \
  "$ROOT_DIR/pythonscad/tube-clamp/tube_clamp.py"

if [[ ! -s "$PYTHONSCAD_OUT" ]]; then
  echo "ERROR: PythonSCAD tube-clamp produced no verification PNG" >&2
  exit 1
fi

echo
echo "Standalone verification renders updated:"
echo "  $OPENSCAD_OUT"
echo "  $PYTHONSCAD_OUT"
