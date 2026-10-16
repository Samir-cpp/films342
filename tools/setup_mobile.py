#!/usr/bin/env python3
"""Install a pinned, verified Android CLI and configure local Godot paths.

Linux bootstrap only; macOS users can supply an existing ANDROID_HOME SDK.
Use --accept-sdk-licenses when installing missing Android components.
"""
import argparse,hashlib,json,os,pathlib,re,shutil,subprocess,sys,urllib.request,zipfile
ROOT=pathlib.Path(__file__).resolve().parents[1]
CLI_URL='https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip'
CLI_SHA256='7ec965280a073311c339e571cd5de778b9975026cfcbe79f2b1cdcb1e15317ee'
def run(args,env,**kwargs):
 return subprocess.run([str(x) for x in args],check=True,env=env,**kwargs)
def setup(accept=False):
 sdk=pathlib.Path(os.environ.get('ANDROID_HOME',ROOT/'.tools/android-sdk')).resolve()
 env=os.environ.copy()
 env.update(ANDROID_HOME=str(sdk),ANDROID_SDK_ROOT=str(sdk),ANDROID_USER_HOME=str(ROOT/'.tools/android-user'),XDG_DATA_HOME=str(ROOT/'.tools/data'))
 pathlib.Path(env['ANDROID_USER_HOME']).mkdir(parents=True,exist_ok=True)
 java_bin=shutil.which('java')
 if not java_bin:raise SystemExit('Install OpenJDK 17 or newer before building Android.')
 java=pathlib.Path(java_bin).resolve().parents[1]
 env['JAVA_HOME']=str(java)
 env['JAVA_TOOL_OPTIONS']='-Duser.home='+str(ROOT/'.tools/home')
 ready=all((sdk/p).exists() for p in ['platform-tools/adb','build-tools/35.0.1/apksigner','platforms/android-35/android.jar'])
 if not ready:
  if not accept:raise SystemExit('SDK packages missing. Run python3 tools/setup_mobile.py --accept-sdk-licenses to install them under .tools/.')
  manager=sdk/'cmdline-tools/19.0/bin/sdkmanager'
  if not manager.exists():
   if sys.platform!='linux':raise SystemExit('Install Android Studio SDK tools and set ANDROID_HOME on this platform.')
   archive=ROOT/'.tools/android-cli-19.zip';archive.parent.mkdir(exist_ok=True)
   with urllib.request.urlopen(CLI_URL,timeout=120) as src,archive.open('wb') as dst:shutil.copyfileobj(src,dst)
   if hashlib.sha256(archive.read_bytes()).hexdigest()!=CLI_SHA256:raise SystemExit('Android CLI checksum mismatch; refusing to use archive.')
   with zipfile.ZipFile(archive) as z:
    for item in z.infolist():
     if item.is_dir():continue
     relative=pathlib.PurePosixPath(item.filename).relative_to('cmdline-tools')
     if '..' in relative.parts:raise SystemExit('Unsafe archive path')
     target=sdk/'cmdline-tools/19.0'/relative
     target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(z.read(item))
     if relative.parts[0]=='bin':target.chmod(0o755)
  run([manager,'--sdk_root='+str(sdk),'--licenses'],env,input='y\n'*300,text=True)
  run([manager,'--sdk_root='+str(sdk),'platform-tools','build-tools;35.0.1','platforms;android-35'],env)
 # Use the same project-local EditorSettings file as tools/setup.sh.
 settings=ROOT/'.tools/home/.config/godot/editor_settings-4.6.tres'
 if not settings.exists():raise SystemExit('Run bash tools/setup.sh first to create editor settings.')
 text=settings.read_text()
 for key,value in {'export/android/java_sdk_path':str(java),'export/android/android_sdk_path':str(sdk)}.items():
  setting=key+' = '+json.dumps(value)
  if re.search('^'+re.escape(key)+' = .*',text,re.M):text=re.sub('^'+re.escape(key)+' = .*',setting,text,flags=re.M)
  else:text+='\n'+setting+'\n'
 settings.write_text(text)
 print('Android SDK configured:',sdk)
 return sdk
if __name__=='__main__':
 parser=argparse.ArgumentParser();parser.add_argument('--accept-sdk-licenses',action='store_true')
 setup(parser.parse_args().accept_sdk_licenses)
