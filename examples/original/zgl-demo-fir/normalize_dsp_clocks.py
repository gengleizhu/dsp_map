"""Connect combinational DSP clock pins to the fabric's sole global clock."""
import collections
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
design = json.loads(path.read_text())
cells = design['modules']['top_wrapper']['cells']
clock = cells['clk_i']['connections']['CLK']
dsps = [cell for cell in cells.values() if cell['type'] == 'MULADD']
assert len(dsps) == 6, f'Expected six mapped DSPs, got {len(dsps)}'
for cell in dsps:
    for parameter in ('A_reg', 'B_reg', 'C_reg', 'ACC'):
        assert int(cell['parameters'][parameter], 2) == 0, parameter
    cell['connections']['CLK'] = clock[:]
for name in list(cells):
    if name != 'clk_i' and cells[name]['type'] == 'Global_Clock':
        del cells[name]
path.write_text(json.dumps(design))
counts = collections.Counter(cell['type'] for cell in cells.values())
Path('logs/13-resource-count.json').write_text(json.dumps(counts, indent=2))
print('Connected six combinational DSPs to clk_i. Resource counts:')
print(json.dumps(counts, indent=2))
