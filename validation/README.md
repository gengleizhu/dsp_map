# Validation record

Validated on 2026-09-24 in the Rocky Linux FABulous environment.

- Yosys: 0.68 (`38e001a6f`)
- Shell syntax: portable and original build scripts passed `bash -n`
- Python syntax: normalization scripts passed `python3 -m py_compile`
- Synthesis smoke test: `tests/run_smoke.sh`
- Result: `DSP_MAP_SMOKE_PASS`
- Mapped cells: one `MULADD` and one temporary `Global_Clock`

The smoke test synthesizes `tests/mul_smoke.v` with `synth_fabulous` and fails
unless the resulting JSON contains a `MULADD` cell. The temporary clock is
expected at this stage and is consolidated by `scripts/normalize_dsp_clocks.py`
in a complete generated-project flow.
