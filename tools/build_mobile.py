#!/usr/bin/env python3
"""Produce an installable Android TEST APK and an unsigned iOS Xcode project.

This does not publish to a store or create an iOS IPA. Never commit signing keys.
"""
import argparse,hashlib,os,pathlib,shutil,subprocess,sys,zipfile
from setup_mobile import setup
ROOT=pathlib.Path(__file__).resolve().parents[1]
def run(args,env,log=None):
 if log:
  with log.open('w') as output:subprocess.run([str(x) for x in args],cwd=ROOT,env=env,stdout=output,stderr=subprocess.STDOUT,check=True)
 else:subprocess.run([str(x) for x in args],cwd=ROOT,env=env,check=True)
def build(accept=False):
 # Linux cloud setup already retains verified Godot export templates.
 subprocess.run(['bash','tools/setup.sh','--exports'],cwd=ROOT,check=True)
 sdk=setup(accept)
 env=os.environ.copy();env.update(HOME=str(ROOT/'.tools/home'),XDG_DATA_HOME=str(ROOT/'.tools/data'),XDG_CACHE_HOME=str(ROOT/'.tools/cache'))
 godot=(ROOT/'.tools/godot-path').read_text().strip()
 templates=ROOT/'.tools/data/godot/export_templates/4.6.3.stable'
 if not all((templates/p).exists() for p in ['android_debug.apk','android_release.apk','ios.zip']):
  archive=pathlib.Path('/tmp/Godot_v4.6.3-stable_export_templates.tpz')
  if not archive.exists():archive=ROOT/'.tools/Godot_v4.6.3-stable_export_templates.tpz'
  if not archive.exists():
   import urllib.request
   with urllib.request.urlopen('https://github.com/godotengine/godot/releases/download/4.6.3-stable/Godot_v4.6.3-stable_export_templates.tpz',timeout=120) as src,archive.open('wb') as dst:shutil.copyfileobj(src,dst)
  expected=(ROOT/'docs/export-templates.sha512').read_text().split()[0]
  digest=hashlib.sha512()
  with archive.open('rb') as src:
   for chunk in iter(lambda:src.read(1024*1024),b''):digest.update(chunk)
  if digest.hexdigest()!=expected:raise SystemExit('Official template checksum mismatch')
  with zipfile.ZipFile(archive) as z:
   for name in ['android_debug.apk','android_release.apk','ios.zip']:(templates/name).write_bytes(z.read('templates/'+name))
 android=ROOT/'builds/android';ios=ROOT/'builds/ios'
 android.mkdir(parents=True,exist_ok=True);ios.mkdir(parents=True,exist_ok=True)
 apk=android/'TheDirector-Android.apk'
 run([godot,'--headless','--path',ROOT,'--export-debug','Android',apk],env,ROOT/'.tools/export-Android.log')
 if not apk.exists():raise SystemExit('No Android package generated')
 run([sdk/'build-tools/35.0.1/apksigner','verify','--verbose',apk],env)
 run([godot,'--headless','--path',ROOT,'--export-release','iOS',ios/'TheDirector.zip'],env,ROOT/'.tools/export-iOS.log')
 if not (ios/'TheDirector.xcodeproj/project.pbxproj').exists():raise SystemExit('No Xcode project generated')
 for folder in [android,ios]:
  for source in ['LICENSE','docs/GODOT_COPYRIGHT.txt','assets/fonts/OFL.txt','docs/MOBILE.md']:shutil.copy2(ROOT/source,folder/pathlib.Path(source).name)
 for folder,name,prefix in [(android,'TheDirector-Android.zip','TheDirector-Android'),(ios,'TheDirector-iOS-Xcode.zip','TheDirector-iOS')]:
  with zipfile.ZipFile(ROOT/'builds'/name,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
   for source in sorted(folder.rglob('*')):
    if source.is_file() and source.suffix!='.idsig':z.write(source,prefix+'/'+str(source.relative_to(folder)))
 shutil.copy2(apk,ROOT/'builds/TheDirector-Android.apk')
 print('Mobile packages ready. Android is debug-signed for testing; iOS is an unsigned Xcode project, not an installable IPA.')
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--accept-sdk-licenses',action='store_true')
 build(parser.parse_args().accept_sdk_licenses)
