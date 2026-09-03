#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

OPENSCAD_SOURCE="$ROOT_DIR/openscad/tube-clamp/tube_clamp_render.scad"
OPENSCAD_OUT="$ROOT_DIR/openscad/tube-clamp/design/img"

PYTHONSCAD_SOURCE="$ROOT_DIR/pythonscad/tube-clamp/tube_clamp_render.py"
PYTHONSCAD_OUT="$ROOT_DIR/pythonscad/tube-clamp/design/img"

mkdir -p "$OPENSCAD_OUT" "$PYTHONSCAD_OUT"

OPENSCAD_EXPECTED_IMAGES=(
  "01-outer-ring.png"
  "02-base.png"
  "03-transition.png"
  "04-bore.png"
  "05-opening.png"
  "06-final.png"
  "07-profile.png"
)

PYTHONSCAD_EXPECTED_IMAGES=(
  "01-outer-ring.png"
  "02-base.png"
  "03-transition.png"
  "04-bore.png"
  "05-opening.png"
  "06-final.png"
  "07-profile.png"
)

prune_stale_pngs() {
  local dir="$1"
  shift

  local file
  local expected
  local keep

  shopt -s nullglob
  for file in "$dir"/*.png; do
    keep=false

    for expected in "$@"; do
      if [[ "$(basename "$file")" == "$expected" ]]; then
        keep=true
        break
      fi
    done

    if [[ "$keep" == false ]]; then
      echo "Removing stale design image: $file"
      rm -f "$file"
    fi
  done
  shopt -u nullglob
}

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

run_checked "OpenSCAD 01-outer-ring" \
  openscad --enable=object-function "${common_args[@]}" \
  -D 'design_view=1' \
  -o "$OPENSCAD_OUT/01-outer-ring.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 02-base" \
  openscad --enable=object-function "${common_args[@]}" \
  -D 'design_view=2' \
  -o "$OPENSCAD_OUT/02-base.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 03-transition" \
  openscad --enable=object-function "${common_args[@]}" \
  -D 'design_view=3' \
  -o "$OPENSCAD_OUT/03-transition.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 04-bore" \
  openscad --enable=object-function "${common_args[@]}" \
  -D 'design_view=4' \
  -o "$OPENSCAD_OUT/04-bore.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 05-opening" \
  openscad --enable=object-function "${common_args[@]}" \
  -D 'design_view=5' \
  -o "$OPENSCAD_OUT/05-opening.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 06-final" \
  openscad --enable=object-function "${common_args[@]}" \
  -D 'design_view=0' \
  -o "$OPENSCAD_OUT/06-final.png" \
  "$OPENSCAD_SOURCE"

run_checked "OpenSCAD 07-profile" \
  openscad --enable=object-function "${common_args[@]}" \
  --camera=0,0,0,0,0,0,100 \
  -D 'design_view=6' \
  -o "$OPENSCAD_OUT/07-profile.png" \
  "$OPENSCAD_SOURCE"

echo
echo "== PythonSCAD design images =="

run_checked "PythonSCAD 01-outer-ring" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="Outer ring"' \
  -o "$PYTHONSCAD_OUT/01-outer-ring.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 02-base" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="Compact base"' \
  -o "$PYTHONSCAD_OUT/02-base.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 03-transition" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="Base transition"' \
  -o "$PYTHONSCAD_OUT/03-transition.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 04-bore" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="Tube bore"' \
  -o "$PYTHONSCAD_OUT/04-bore.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 05-opening" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="Snap opening"' \
  -o "$PYTHONSCAD_OUT/05-opening.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 06-final" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  -D 'design_view="Final clamp"' \
  -o "$PYTHONSCAD_OUT/06-final.png" \
  "$PYTHONSCAD_SOURCE"

run_checked "PythonSCAD 07-profile" \
  xvfb-run -a pythonscad "${common_args[@]}" \
  --trust-python \
  --camera=0,0,0,0,0,0,100 \
  -D 'design_view="Profile view"' \
  -o "$PYTHONSCAD_OUT/07-profile.png" \
  "$PYTHONSCAD_SOURCE"

echo
echo "== Pruning stale design images =="

prune_stale_pngs "$OPENSCAD_OUT" "${OPENSCAD_EXPECTED_IMAGES[@]}"
prune_stale_pngs "$PYTHONSCAD_OUT" "${PYTHONSCAD_EXPECTED_IMAGES[@]}"

echo
echo "Design images updated."
