import collections
import json
import sys
from pathlib import Path

p=Path(sys.argv[1]); design=json.loads(p.read_text()); cells=design['modules']['top_wrapper']['cells']
clock=cells['clk_i']['connections']['CLK']
dsps=[c for c in cells.values() if c['type']=='MULADD']
assert 0<len(dsps)<=62, len(dsps)
for c in dsps:
    for param in ('A_reg','B_reg','C_reg','ACC'):
        assert int(c['parameters'][param],2)==0
    c['connections']['CLK']=clock[:]
for name in list(cells):
    if name!='clk_i' and cells[name]['type']=='Global_Clock': del cells[name]
assert not [c['type'] for c in cells.values() if c['type'].startswith('$') and c['type']!='$scopeinfo']
ios=[c for c in cells.values() if c['type']=='IO_1_bidirectional_frame_config_pass']
assert len(ios)==33,len(ios)
assert len({c['attributes']['BEL'] for c in ios})==33
p.write_text(json.dumps(design))
counts=collections.Counter(c['type'] for c in cells.values())
Path('logs/fir64/resources.json').write_text(json.dumps(counts,indent=2))
print(json.dumps(counts,indent=2))
