#!/usr/bin/env bash
set -euo pipefail

export PATH=/nix/store/9ysyys63a84rasqkdzdsjjha1fyr9ads-FABulous-env/bin:/home/zyzhao/miniforge3/envs/fabulous/bin:/usr/bin:/bin
export PYTHONPATH=/home/zyzhao/FABulous
unset LD_LIBRARY_PATH PYTHONHOME

cd /home/zyzhao/FABulous/zgl-64x64-picorv32-test/Test

export PICORV_LOG_DIR="logs/picorv32/run-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$PICORV_LOG_DIR"

SYNTH_ARGS='-extra-plib yosys-0.68-maps/prims.v -cells-map yosys-0.68-maps/cells_map.v -extra-map yosys-0.68-maps/ff_map.v -extra-map yosys-0.68-maps/io_map.v -extra-mlibmap yosys-0.68-maps/ram_regfile.txt -extra-map yosys-0.68-maps/regfile_map.v -ff \$_DFF_P_ 0 -multiplier-map yosys-0.68-maps/mul_map.v 8 8 1 1 1'

task build-test-design DESIGN=picorv32_top \
YOSYS_PATH=/home/zyzhao/.fabulous/yosys-0.68/bin/yosys \
YOSYS_EXTRA_ARGS="-l $PICORV_LOG_DIR/yosys.log" \
POST_SYNTH_SCRIPT=normalize_pico_clocks.py \
SYNTH_EXTRA_ARGS="$SYNTH_ARGS" \
NEXTPNR_PATH=/nix/store/rwc7bibpqi9hprxkjynfd9c5vjflxkij-nextpnr-unstable/bin/nextpnr-generic \
LOG_FILE="$PICORV_LOG_DIR/nextpnr.log" \
NEXTPNR_EXTRA_ARGS="--freq ${FREQ_MHZ:-5} --placer heap --router router2 --seed 1 --threads 4 --placer-heap-beta 0.65 --report $PICORV_LOG_DIR/nextpnr-report.json --write build/picorv32_top-routed-${FREQ_MHZ:-10}MHz.json" \
2>&1 | tee "$PICORV_LOG_DIR/build.log"
