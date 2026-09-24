set -e
. "$HOME/.nix-profile/etc/profile.d/nix.sh"
export NIX_SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt
cd /home/zyzhao/FABulous
nix develop --offline --no-write-lock-file --accept-flake-config .#nix-env --command bash -c '
set -e
cd /home/zyzhao/FABulous/zgl-demo/Test
task build-test-design DESIGN=fir_filter \
YOSYS_PATH=/home/zyzhao/.fabulous/yosys-0.68/bin/yosys \
YOSYS_EXTRA_ARGS="-l logs/13-yosys-physical.log" \
POST_SYNTH_SCRIPT=normalize_dsp_clocks.py \
NEXTPNR_PATH=nextpnr-generic \
LOG_FILE=logs/14-nextpnr-physical-10MHz.log \
NEXTPNR_EXTRA_ARGS="--freq 10" \
SYNTH_EXTRA_ARGS="-extra-plib yosys-0.68-maps/prims.v -cells-map yosys-0.68-maps/cells_map.v -extra-map yosys-0.68-maps/ff_map.v -extra-map yosys-0.68-maps/io_map.v -ff \\\$_DFF_P_ 0 -multiplier-map yosys-0.68-maps/mul_map.v 8 8 4 4 1"
' > zgl-demo/Test/logs/13-build-test-design-physical.log 2>&1
