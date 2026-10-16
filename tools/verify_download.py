import hashlib,pathlib,sys
path=pathlib.Path(sys.argv[1]);manifest=pathlib.Path(sys.argv[2])
expected=next(line.split()[0] for line in manifest.read_text().splitlines() if line.split()[-1].lstrip('*')==path.name)
hash_value=hashlib.sha512()
with path.open('rb') as file:
 for chunk in iter(lambda:file.read(1024*1024),b''): hash_value.update(chunk)
if hash_value.hexdigest()!=expected: raise SystemExit('SHA-512 mismatch: '+path.name)
print('SHA-512 verified:',path.name)
