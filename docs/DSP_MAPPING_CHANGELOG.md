# DSP mapping change record

## Objective

Map supported Verilog multiplication operations to the FABulous `MULADD` BEL
instead of implementing every multiplier with LUTs.

## Implemented changes

1. Added `maps/mul_map.v`, a Yosys techmap module named
   `$__FABULOUS_MUL`.
2. Limited hard-DSP mapping to operands up to 8 bits and results up to 16
   bits. Unsupported widths fall back through `_TECHMAP_FAIL_`.
3. Connected the `MULADD` C input to zero and disabled its optional input,
   accumulator, and output-register modes so the BEL implements a
   combinational multiply.
4. Added signed-operand correction around the unsigned 8x8 `MULADD` result.
   This is the final mapping used by the 64x64 FIR/PicoRV32 projects. The first
   FIR-only revision accepted unsigned operands only.
5. Added `scripts/normalize_dsp_clocks.py` to connect every combinational
   `MULADD.CLK` pin to the wrapper's existing global clock and remove temporary
   `Global_Clock` cells before nextpnr.
6. Enabled the map through `synth_fabulous` with:

   ```text
   -multiplier-map yosys-0.68-maps/mul_map.v 8 8 1 1 1
   ```

## Files that participate in the flow

- `maps/mul_map.v`: `$mul` to `MULADD` technology mapping.
- `maps/prims.v`: black-box declarations for FABulous primitives, including
  `MULADD` and `Global_Clock`.
- `maps/cells_map.v`, `ff_map.v`, and `io_map.v`: companion maps required by
  the tested `synth_fabulous` invocation.
- `maps/regfile_map.v` and `ram_regfile.txt`: optional RegFile mapping used by
  the PicoRV32 example.
- `scripts/normalize_dsp_clocks.py`: post-synthesis JSON normalization.
- `scripts/build_fabulous_design.sh`: portable task wrapper with logs.

## Mapping limits

- Maximum mapped operand width: 8 bits per operand.
- Maximum mapped result width: 16 bits.
- Wider multipliers are intentionally left for another implementation.
- Signed multiplication uses correction logic outside the DSP, which consumes
  some LUT resources.
- The mapping assumes the architecture exposes a `MULADD` BEL with the port
  and parameter names declared in `maps/prims.v`.

## Original validation cases

- FIR filter: multiplication mapped to `MULADD`, followed by synthesis,
  nextpnr place-and-route, and bitstream generation.
- PicoRV32: 24 `MULADD` cells were recorded by the project-specific
  post-synthesis validation script.

The scripts in `examples/original/` preserve the commands used in those
projects. They contain their original absolute paths and are included for
traceability; use the portable scripts at repository root for migration.
