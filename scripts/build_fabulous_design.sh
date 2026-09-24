#!/usr/bin/env bash
set -euo pipefail

: "${PROJECT_ROOT:?Set PROJECT_ROOT to the FABulous project directory}"
: "${DESIGN:?Set DESIGN to the user-design top name}"

project_root="$(realpath "$PROJECT_ROOT")"
test_dir="$project_root/Test"
timestamp="$(date +%Y%m%d-%H%M%S)"
log_dir="${LOG_DIR:-$test_dir/logs/$DESIGN/run-$timestamp}"

YOSYS_PATH="${YOSYS_PATH:-$HOME/.fabulous/yosys-0.68/bin/yosys}"
NEXTPNR_PATH="${NEXTPNR_PATH:-nextpnr-generic}"
FREQ_MHZ="${FREQ_MHZ:-10}"
POST_SYNTH_SCRIPT="${POST_SYNTH_SCRIPT:-normalize_dsp_clocks.py}"

mkdir -p "$log_dir"
cd "$test_dir"

synth_args='-extra-plib yosys-0.68-maps/prims.v -cells-map yosys-0.68-maps/cells_map.v -extra-map yosys-0.68-maps/ff_map.v -extra-map yosys-0.68-maps/io_map.v -ff \$_DFF_P_ 0 -multiplier-map yosys-0.68-maps/mul_map.v 8 8 1 1 1'

task build-test-design \
    DESIGN="$DESIGN" \
    YOSYS_PATH="$YOSYS_PATH" \
    YOSYS_EXTRA_ARGS="-l $log_dir/yosys.log" \
    POST_SYNTH_SCRIPT="$POST_SYNTH_SCRIPT" \
    SYNTH_EXTRA_ARGS="$synth_args" \
    NEXTPNR_PATH="$NEXTPNR_PATH" \
    LOG_FILE="$log_dir/nextpnr.log" \
    NEXTPNR_EXTRA_ARGS="--freq $FREQ_MHZ ${NEXTPNR_EXTRA_ARGS:-}" \
    2>&1 | tee "$log_dir/build.log"

echo "Logs: $log_dir"
