"""Validate every JSON document against bundled schemas plus gameplay invariants."""
import json,pathlib
root=pathlib.Path(__file__).resolve().parents[1]/'data'
data={p.stem:json.loads(p.read_text()) for p in root.glob('*.json')}
def validate(value,schema,path):
 types={'array':list,'object':dict,'string':str,'number':(int,float),'integer':int,'boolean':bool}
 if 'type' in schema: assert isinstance(value,types[schema['type']]),path
 if 'enum' in schema:assert value in schema['enum'],path
 if isinstance(value,(int,float)) and not isinstance(value,bool):
  assert value>=schema.get('minimum',float('-inf')),path
  assert value<=schema.get('maximum',float('inf')),path
 if isinstance(value,dict):
  for key in schema.get('required',[]): assert key in value,(path,key)
  for key,child in schema.get('properties',{}).items():
   if key in value: validate(value[key],child,path+'.'+key)
 if isinstance(value,list):
  assert len(value)>=schema.get('minItems',0),path
  assert len(value)<=schema.get('maxItems',100000),path
  for i,item in enumerate(value):validate(item,schema.get('items',{}),f'{path}[{i}]')
 if isinstance(value,str):assert len(value)>=schema.get('minLength',0),path
count=0
for key,schema in data['schemas'].items():
 validate(data[key],schema,key)
 if isinstance(data[key],list):
  ids=[r['id'] for r in data[key]]
  assert len(set(ids))==len(ids),key
  count+=len(ids)
for event in data['events']:
 assert event['conditions']['stage'] in data['content']['stages']
for key in ['actors','actresses','crew','new_talent']:
 for p in data[key]:
  assert 0<=p['skill']<=100 and 0<=p['availability']<=1
  assert p['fee_range'][1]>=p['fee_range'][0]>=0
assert len(data['events'])>=150
assert len(data['benchmark_films'])==40
assert count>=300
print(f'PASS: {len(data)-1} schema-validated documents, {count} records, 150 event records, 40 synthetic benchmarks.')
