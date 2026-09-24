#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
yosys="${YOSYS_PATH:-$HOME/.fabulous/yosys-0.68/bin/yosys}"
json_file="$repo_root/tests/.mul_smoke.json"
log_file="$repo_root/tests/.mul_smoke.log"
trap 'rm -f "$json_file" "$log_file"' EXIT

cd "$repo_root"
cat > tests/.mul_smoke.ys <<'YOSYS'
read_verilog tests/mul_smoke.v
synth_fabulous -top mul_smoke -json tests/.mul_smoke.json \
  -extra-plib maps/prims.v \
  -cells-map maps/cells_map.v \
  -extra-map maps/ff_map.v \
  -extra-map maps/io_map.v \
  -ff $_DFF_P_ 0 \
  -multiplier-map maps/mul_map.v 8 8 1 1 1
stat
YOSYS
trap 'rm -f "$json_file" "$log_file" "$repo_root/tests/.mul_smoke.ys"' EXIT

"$yosys" -l "$log_file" -s tests/.mul_smoke.ys
grep -q '"type": "MULADD"' "$json_file"
echo "DSP_MAP_SMOKE_PASS: one 8x8 multiply mapped to MULADD"
