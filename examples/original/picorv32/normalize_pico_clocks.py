import json,collections,sys,os
from pathlib import Path
p=Path(sys.argv[1] if len(sys.argv)>1 else 'build/picorv32_top.json');j=json.loads(p.read_text());cells=j['modules']['top_wrapper']['cells'];clk=cells['clk_i']['connections']['CLK']
dsps=[c for c in cells.values() if c['type']=='MULADD'];assert len(dsps)==24,len(dsps)
for c in dsps:
 for k in ('A_reg','B_reg','C_reg','ACC'):assert int(c['parameters'][k],2)==0
 c['connections']['CLK']=clk[:]
for name in list(cells):
 if cells[name]['type']=='Global_Clock' and name!='clk_i':del cells[name]
for c in cells.values():
 if c['type']=='RegFile_32x4':assert c['connections']['CLK']==clk,c
p.write_text(json.dumps(j))
counts=collections.Counter(c['type'] for c in cells.values())
assert not any(t.startswith('$') and t!='$scopeinfo' for t in counts),counts
(Path(os.environ.get('PICORV_LOG_DIR','logs/picorv32'))/'07-resources.json').write_text(json.dumps(counts,indent=2))
print(json.dumps(counts,indent=2))
