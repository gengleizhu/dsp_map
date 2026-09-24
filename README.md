# FABulous DSP mapping

This repository packages the Yosys mapping used to map supported Verilog
multiplication operations onto the FABulous `MULADD` DSP BEL. It also records
the FIR and PicoRV32 build scripts that were used to verify synthesis,
place-and-route, and bitstream generation on the 64x64 fabric.

## What is mapped

- Unsigned and signed multiplications with operand widths up to 8 bits.
- Result widths up to 16 bits.
- Each supported multiplication becomes one `MULADD` cell.
- Wider operations fail this techmap and remain available for another mapping
  or LUT implementation.

Signed multiplication adds correction logic around the unsigned DSP result,
so it may consume LUTs in addition to the `MULADD` cell.

## Install into a FABulous project

```bash
git clone https://github.com/gengleizhu/dsp_map.git
cd dsp_map
chmod +x scripts/*.sh
./scripts/install_maps.sh /home/zyzhao/FABulous/my-project
cp scripts/normalize_dsp_clocks.py \
  /home/zyzhao/FABulous/my-project/Test/
```

The project must already contain the generated fabric, `top_wrapper`, nextpnr
model, and a working `Test/Taskfile.yml`.

## Build a design

```bash
PROJECT_ROOT=/home/zyzhao/FABulous/my-project \
DESIGN=my_top \
FREQ_MHZ=10 \
POST_SYNTH_SCRIPT=normalize_dsp_clocks.py \
YOSYS_PATH=/home/zyzhao/.fabulous/yosys-0.68/bin/yosys \
NEXTPNR_PATH=nextpnr-generic \
./scripts/build_fabulous_design.sh
```

The wrapper writes separate `yosys.log`, `nextpnr.log`, and `build.log` files
under a timestamped directory in `Test/logs/<design>/`.

## Verify the result

Check the resource report or synthesis log for `MULADD` cells:

```bash
grep -E 'MULADD|Device utilisation' Test/logs/<design>/run-*/yosys.log
grep -E 'MULADD|Device utilisation' Test/logs/<design>/run-*/nextpnr.log
```

The generic clock-normalization script accepts optional checks:

```bash
python normalize_dsp_clocks.py build/my_top.json \
  --expected-dsps 10 \
  --resource-report logs/my_top/resources.json
```

Run the standalone synthesis smoke test with:

```bash
YOSYS_PATH=/home/zyzhao/.fabulous/yosys-0.68/bin/yosys \
  ./tests/run_smoke.sh
```

The test passes only when the generated JSON contains a `MULADD` cell.

## Repository layout

- `maps/`: tested Yosys/FABulous technology maps.
- `scripts/`: portable installation, build, and JSON-normalization helpers.
- `examples/original/`: original FIR and PicoRV32 scripts for traceability.
- `docs/DSP_MAPPING_CHANGELOG.md`: implementation details and limitations.
- `tests/mul_smoke.v`: minimal multiplier source for synthesis checks.
- `tests/run_smoke.sh`: verifies that an 8x8 multiply becomes `MULADD`.
