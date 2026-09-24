#!/usr/bin/env bash
set -euo pipefail
export PATH=/nix/store/9ysyys63a84rasqkdzdsjjha1fyr9ads-FABulous-env/bin:/home/zyzhao/miniforge3/envs/fabulous/bin:/usr/bin:/bin
export PYTHONPATH=/home/zyzhao/FABulous
unset LD_LIBRARY_PATH PYTHONHOME
cd /home/zyzhao/FABulous/zgl-64x64-fir/Test
mkdir -p logs/fir64
exec > >(tee logs/fir64/build.log) 2>&1
set -x
SYNTH_ARGS='-extra-plib yosys-0.68-maps/prims.v -cells-map yosys-0.68-maps/cells_map.v -extra-map yosys-0.68-maps/ff_map.v -extra-map yosys-0.68-maps/io_map.v -ff \$_DFF_P_ 0 -multiplier-map yosys-0.68-maps/mul_map.v 8 8 1 1 1'
task build-test-design DESIGN=fir_filter \
YOSYS_PATH=/home/zyzhao/.fabulous/yosys-0.68/bin/yosys \
YOSYS_EXTRA_ARGS='-l logs/fir64/yosys.log' \
POST_SYNTH_SCRIPT=normalize_fir64.py \
SYNTH_EXTRA_ARGS="$SYNTH_ARGS" \
NEXTPNR_PATH=/nix/store/rwc7bibpqi9hprxkjynfd9c5vjflxkij-nextpnr-unstable/bin/nextpnr-generic \
LOG_FILE=logs/fir64/nextpnr-10MHz.log \
NEXTPNR_EXTRA_ARGS="--freq ${FREQ_MHZ:-10} --placer heap --router router2 --seed 1 --threads 4 --placer-heap-beta 0.65 --report logs/fir64/nextpnr-report.json --write build/fir_filter-routed.json"
echo BUILD_COMPLETE
