#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
    echo "ERROR: run bootstrap.sh from inside the lib.scad.clamps repository." >&2
    exit 1
fi

cd "$repo_root"

path="tools/tool.scad-project"
url="$(git config -f .gitmodules --get "submodule.tools/tool.scad-project.url")"

if ! git ls-files --stage -- "$path" 2>/dev/null | grep -q '^160000 '; then
    if [[ -d "$path" && -n "$(ls -A "$path" 2>/dev/null)" && ! -e "$path/.git" ]]; then
        echo "ERROR: $path contains non-Git files." >&2
        exit 1
    fi

    if [[ -d "$path" && -z "$(ls -A "$path" 2>/dev/null)" ]]; then
        rmdir "$path"
    fi

    git submodule add --force "$url" "$path"
fi

git submodule sync --recursive
git submodule update --init --recursive

echo
echo "Bootstrap complete."
git submodule status --recursive
