#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"
OUT_DIR="${ROOT_DIR}/vrf/out"

mkdir -p \
  "${OUT_DIR}/openscad" \
  "${OUT_DIR}/pythonscad"

# Step 0.5 repository/tooling boundary checks.
if ! grep -Fq 'type: scad' project.yml || ! grep -Fq 'config: project.scad.yml' project.yml; then
  echo "ERROR: project.yml must declare project.scad.yml as the SCAD profile" >&2
  exit 1
fi

if grep -Fq 'name: tool.git-project' project.yml; then
  echo "ERROR: tool.git-project must be pinned directly by the parent gitlink, not managed recursively" >&2
  exit 1
fi

for path in tools/tool.git-project tools/tool.scad-project; do
  if ! git ls-files --stage -- "$path" | grep -q '^160000 '; then
    echo "ERROR: expected committed direct gitlink is missing: $path" >&2
    exit 1
  fi
done

TOOL_REF="$(awk '
  $1 == "-" && $2 == "name:" { in_tool = ($3 == "tool.scad-project"); next }
  in_tool && $1 == "ref:" { print $2; exit }
' project.yml)"
TOOL_SHA="$(git -C tools/tool.scad-project rev-parse HEAD)"
RESOLVED_REF_SHA="$(git -C tools/tool.scad-project rev-parse "${TOOL_REF}^{commit}" 2>/dev/null || true)"
if [[ -z "$TOOL_REF" || "$RESOLVED_REF_SHA" != "$TOOL_SHA" ]]; then
  echo "ERROR: project.yml tool.scad-project ref and gitlink are not aligned" >&2
  exit 1
fi

for mapping in \
  "scad.yml:project-production" \
  "release.yml:project-release" \
  "pr-cleanup.yml:project-pr-cleanup"; do
  caller="${mapping%%:*}"
  reusable="${mapping#*:}"
  expected="brainboxemb/tool.scad-project/.github/workflows/${reusable}.yml@${TOOL_SHA}"
  if ! grep -Fq "$expected" ".github/workflows/${caller}"; then
    echo "ERROR: .github/workflows/${caller} is not pinned to exact tooling commit ${TOOL_SHA}" >&2
    exit 1
  fi
done

if [[ -e .github/workflows/design-build.yml || -e .github/workflows/verify.yml ]]; then
  echo "ERROR: standalone Build/Verify callers must not coexist with common SCAD production orchestration" >&2
  exit 1
fi

for required in \
  'affected_task: consumer:scad.production-impact' \
  'aggregate_task: consumer:scad.ci' \
  'cache_namespace: lib-scad-clamps-production-v1'; do
  if ! grep -Fq "$required" .github/workflows/scad.yml; then
    echo "ERROR: scad.yml is missing common production caller contract: ${required}" >&2
    exit 1
  fi
done

for required in \
  'scad.docs:' \
  'scad.build-index:' \
  'scad.build-provenance:' \
  'scad.verify:' \
  'scad.verification-provenance:' \
  'scad.production-impact:' \
  'scad.ci:'; do
  if ! grep -Fq "$required" moon.yml; then
    echo "ERROR: moon.yml is missing library production task: ${required}" >&2
    exit 1
  fi
done

if grep -Fq 'scad.build:' moon.yml; then
  echo "ERROR: lib.scad.clamps has no normal configured render/export targets; do not invent an empty scad.build task" >&2
  exit 1
fi

if ! grep -Fq -- "- 'scad.docs'" moon.yml || ! grep -Fq -- "- 'scad.verify'" moon.yml; then
  echo "ERROR: scad.production-impact must cover both library design/docs and consumer verification producers" >&2
  exit 1
fi

if ! cmp -s bootstrap.sh tools/tool.git-project/bootstrap/consumer-bootstrap.sh; then
  echo "ERROR: bootstrap.sh differs from the pinned tool.git-project consumer bootstrap" >&2
  exit 1
fi
if ! cmp -s bootstrap.ps1 tools/tool.git-project/bootstrap/consumer-bootstrap.ps1; then
  echo "ERROR: bootstrap.ps1 differs from the pinned tool.git-project consumer bootstrap" >&2
  exit 1
fi
if ! cmp -s update-repo.sh tools/tool.scad-project/bootstrap/consumer-update.sh; then
  echo "ERROR: update-repo.sh differs from the pinned tool.scad-project SCAD update wrapper" >&2
  exit 1
fi
if ! cmp -s update-repo.ps1 tools/tool.scad-project/bootstrap/consumer-update.ps1; then
  echo "ERROR: update-repo.ps1 differs from the pinned tool.scad-project SCAD update wrapper" >&2
  exit 1
fi

echo "Repository bootstrap and production ownership: OK"

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

# OpenSCAD consumer test.
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

# PythonSCAD consumer test.
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

echo "Verification output written to ${OUT_DIR}"
