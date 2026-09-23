#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"
OUT_DIR="${ROOT_DIR}/vrf/out"

mkdir -p \
  "${OUT_DIR}/openscad" \
  "${OUT_DIR}/pythonscad"

cp "${ROOT_DIR}/doc/50-00-verification.md" "${OUT_DIR}/50-00-verification.md"

run_checked() {
  local label="$1"
  shift

  local log_file
  log_file="$(mktemp)"

  echo "-- ${label}"

  set +e
  "$@" 2>&1 | tee "${log_file}"
  local status=${PIPESTATUS[0]}
  set -e

  if [[ ${status} -ne 0 ]]; then
    echo "ERROR: ${label} failed with exit code ${status}" >&2
    rm -f "${log_file}"
    exit "${status}"
  fi

  if grep -qE '(^|[[:space:]])ERROR:' "${log_file}"; then
    echo "ERROR: ${label} emitted an OpenSCAD/PythonSCAD error" >&2
    rm -f "${log_file}"
    exit 1
  fi

  rm -f "${log_file}"
}

# Exercise the public tube-clamp API as a consumer in both supported engines.
run_checked \
  "OpenSCAD tube-clamp API PNG" \
  openscad \
    --enable=object-function \
    --imgsize=1600,900 \
    --viewall \
    --autocenter \
    -o "${OUT_DIR}/openscad/tube-clamp-api.png" \
    "${ROOT_DIR}/test/openscad/tube_clamp_api.scad"

run_checked \
  "OpenSCAD tube-clamp API STL" \
  openscad \
    --enable=object-function \
    -o "${OUT_DIR}/openscad/tube-clamp-api.stl" \
    "${ROOT_DIR}/test/openscad/tube_clamp_api.scad"

run_checked \
  "PythonSCAD tube-clamp API PNG" \
  xvfb-run -a \
    pythonscad \
      --trust-python \
      --imgsize=1600,900 \
      --viewall \
      --autocenter \
      -o "${OUT_DIR}/pythonscad/tube-clamp-api.png" \
      "${ROOT_DIR}/test/pythonscad/tube_clamp_api.py"

run_checked \
  "PythonSCAD tube-clamp API STL" \
  xvfb-run -a \
    pythonscad \
      --trust-python \
      -o "${OUT_DIR}/pythonscad/tube-clamp-api.stl" \
      "${ROOT_DIR}/test/pythonscad/tube_clamp_api.py"

for output in \
  "${OUT_DIR}/openscad/tube-clamp-api.png" \
  "${OUT_DIR}/openscad/tube-clamp-api.stl" \
  "${OUT_DIR}/pythonscad/tube-clamp-api.png" \
  "${OUT_DIR}/pythonscad/tube-clamp-api.stl"; do
  if [[ ! -s "$output" ]]; then
    echo "ERROR: verification output is missing or empty: $output" >&2
    exit 1
  fi
done

echo "Verification output written to ${OUT_DIR}"
