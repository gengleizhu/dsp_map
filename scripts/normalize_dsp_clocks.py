#!/usr/bin/env python3
"""Connect combinational MULADD clock pins to the fabric global clock.

The FABulous MULADD BEL exposes CLK even when A_reg/B_reg/C_reg/ACC are all
disabled.  The multiplier techmap creates temporary Global_Clock cells.  This
post-synthesis step reuses the wrapper's real clock and removes the temporary
clock cells before nextpnr.
"""

import argparse
import collections
import json
from pathlib import Path


def parameter_is_zero(cell: dict, name: str) -> bool:
    value = cell.get("parameters", {}).get(name, "0")
    return int(value, 2) == 0


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("json_file", type=Path)
    parser.add_argument("--module", default="top_wrapper")
    parser.add_argument("--clock-cell", default="clk_i")
    parser.add_argument("--expected-dsps", type=int)
    parser.add_argument("--resource-report", type=Path)
    args = parser.parse_args()

    design = json.loads(args.json_file.read_text())
    cells = design["modules"][args.module]["cells"]
    clock = cells[args.clock_cell]["connections"]["CLK"]
    dsps = [cell for cell in cells.values() if cell["type"] == "MULADD"]

    if not dsps:
        raise RuntimeError("No MULADD cells were mapped")
    if args.expected_dsps is not None and len(dsps) != args.expected_dsps:
        raise RuntimeError(
            f"Expected {args.expected_dsps} MULADD cells, found {len(dsps)}"
        )

    for cell in dsps:
        for parameter in ("A_reg", "B_reg", "C_reg", "ACC"):
            if not parameter_is_zero(cell, parameter):
                raise RuntimeError(f"MULADD parameter {parameter} must be zero")
        cell["connections"]["CLK"] = list(clock)

    for name in list(cells):
        if name != args.clock_cell and cells[name]["type"] == "Global_Clock":
            del cells[name]

    args.json_file.write_text(json.dumps(design))
    counts = collections.Counter(cell["type"] for cell in cells.values())
    report = json.dumps(counts, indent=2, sort_keys=True)
    print(f"Connected {len(dsps)} MULADD cells to {args.clock_cell}.")
    print(report)

    if args.resource_report:
        args.resource_report.parent.mkdir(parents=True, exist_ok=True)
        args.resource_report.write_text(report + "\n")


if __name__ == "__main__":
    main()
