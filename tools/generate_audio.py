"""Generate this project's original placeholder audio offline, not at app startup."""
import math,pathlib,struct,wave
root=pathlib.Path(__file__).resolve().parents[1]/'assets/audio';root.mkdir(exist_ok=True)
rate=22050
notes=[130.81,164.81,196.0,164.81,110.0,146.83,174.61,146.83]
def save(name,seconds,sample):
 with wave.open(str(root/name),'wb') as f:
  f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate)
  f.writeframes(b''.join(struct.pack('<h',int(max(-32767,min(32767,sample(i/rate))))) for i in range(int(seconds*rate))))
save('calm_loop.wav',16,lambda t:(math.sin(math.tau*notes[int(t/2)%8]*t)+.4*math.sin(math.tau*notes[int(t/2)%8]*2*t))*math.sin(math.pi*(t%2)/2)*.045*16000)
save('click.wav',.065,lambda t:math.sin(math.tau*660*t)*.035*min(1,t*30)*min(1,(.065-t)*8)*32767)
print('Generated original music and UI sound')
