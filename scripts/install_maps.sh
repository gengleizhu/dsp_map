#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/FABulous/project" >&2
    exit 2
fi

project_root="$(realpath "$1")"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$script_dir")"
target="$project_root/Test/yosys-0.68-maps"

test -d "$project_root/Test"
mkdir -p "$target"
cp -a "$repo_root/maps/." "$target/"

echo "Installed DSP/Yosys maps into: $target"
