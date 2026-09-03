#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

OPENSCAD_SOURCE="$ROOT_DIR/openscad/tube-clamp/tube_clamp_render.scad"
OPENSCAD_OUT="$ROOT_DIR/openscad/tube-clamp/design/img"

PYTHONSCAD_SOURCE="$ROOT_DIR/pythonscad/tube-clamp/tube_clamp_render.py"
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
  openscad --enable=object-function "${common_args[@]}" \
  -D 'design_view=1' \
  -o "$OPENSCAD_OUT/01-ring.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 02-opening" \
  openscad --enable=object-function "${common_args[@]}" \
  -D 'design_view=2' \
  -o "$OPENSCAD_OUT/02-opening.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 03-clip-body" \
  openscad --enable=object-function "${common_args[@]}" \
  -D 'design_view=3' \
  -o "$OPENSCAD_OUT/03-clip-body.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 04-foot" \
  openscad --enable=object-function "${common_args[@]}" \
  -D 'design_view=4' \
  -o "$OPENSCAD_OUT/04-foot.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 05-transition" \
  openscad --enable=object-function "${common_args[@]}" \
  -D 'design_view=5' \
  -o "$OPENSCAD_OUT/05-transition.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 06-final" \
  openscad --enable=object-function "${common_args[@]}" \
  -D 'design_view=0' \
  -o "$OPENSCAD_OUT/06-final.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 07-side-view" \
  openscad --enable=object-function "${common_args[@]}" \
  --camera=0,0,0,0,0,0,100 \
  -D 'design_view=6' \
  -o "$OPENSCAD_OUT/07-side-view.png" \
  "$OPENSCAD_SOURCE"

echo
echo "== PythonSCAD design images =="

run_checked "PythonSCAD 01-ring" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="Full ring"' \
  -o "$PYTHONSCAD_OUT/01-ring.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 02-opening" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="Opening cutter"' \
  -o "$PYTHONSCAD_OUT/02-opening.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 03-clip-body" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="Clip body"' \
  -o "$PYTHONSCAD_OUT/03-clip-body.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 04-foot" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="Mounting foot"' \
  -o "$PYTHONSCAD_OUT/04-foot.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 05-transition" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="Foot transition"' \
  -o "$PYTHONSCAD_OUT/05-transition.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 06-final" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="Final clamp"' \
  -o "$PYTHONSCAD_OUT/06-final.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 07-side-view" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  --camera=0,0,0,0,0,0,100 \
  -D 'design_view="Side view"' \
  -o "$PYTHONSCAD_OUT/07-side-view.png" \
  "$PYTHONSCAD_SOURCE"

echo
echo "Design images updated."
