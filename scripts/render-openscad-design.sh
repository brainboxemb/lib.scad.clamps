#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "render-openscad-design.sh is retained as a compatibility wrapper."
echo "Use scripts/render-design-images.sh for both implementations."

exec bash "$ROOT_DIR/scripts/render-design-images.sh"
