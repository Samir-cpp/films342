import pathlib,zipfile
root=pathlib.Path(__file__).resolve().parents[1]
with zipfile.ZipFile(root/'builds/TheDirector-Source.zip','w',zipfile.ZIP_DEFLATED) as archive:
 for path in sorted(root.rglob('*')):
  relative=path.relative_to(root)
  if path.is_file() and not any(part in {'.git','.godot','.tools','builds','downloads','__pycache__'} for part in relative.parts):
   archive.write(path,'TheDirector/'+str(relative))
