extends Node
## Original procedural sounds; no external copyrighted recordings.
var music: AudioStreamPlayer
var ui_sound: AudioStreamPlayer
func tone(frequency: float, seconds: float, volume: float) -> AudioStreamWAV:
 var stream := AudioStreamWAV.new()
 stream.format=AudioStreamWAV.FORMAT_16_BITS
 stream.mix_rate=22050
 var bytes := PackedByteArray()
 bytes.resize(int(seconds*22050)*2)
 for i in range(bytes.size()/2):
  var t: float = i/22050.0
  var envelope: float = minf(1,t*30)*minf(1,(seconds-t)*8)
  var sample: int = int(sin(TAU*frequency*t)*volume*envelope*32767)
  bytes.encode_s16(i*2,sample)
 stream.data=bytes
 return stream
func _ready() -> void:
 if DisplayServer.get_name()=="headless" or "--silent-ui" in OS.get_cmdline_user_args():
  return
 ui_sound=AudioStreamPlayer.new()
 add_child(ui_sound)
 ui_sound.stream=tone(660,.065,.035)
 music=AudioStreamPlayer.new()
 add_child(music)
 var melody := AudioStreamWAV.new()
 melody.format=AudioStreamWAV.FORMAT_16_BITS
 melody.mix_rate=22050
 var bytes := PackedByteArray()
 bytes.resize(22050*16*2)
 var notes := [130.81,164.81,196.0,164.81,110.0,146.83,174.61,146.83]
 for i in range(22050*16):
  var t: float = i/22050.0
  var note: float = notes[int(t/2)%8]
  var envelope: float = sin(PI*fmod(t,2)/2)*.045
  bytes.encode_s16(i*2,int((sin(TAU*note*t)+.4*sin(TAU*note*2*t))*envelope*16000))
 melody.data=bytes
 melody.loop_mode=AudioStreamWAV.LOOP_FORWARD
 melody.loop_end=22050*16
 music.stream=melody
 music.play()
 update_volume()
func click() -> void:
 if ui_sound and GameState.settings.get("sound",true):
  ui_sound.play()
func update_volume() -> void:
 if music:
  music.volume_db=-8 if GameState.settings.get("music",true) else -80

func _exit_tree() -> void:
 if music:
  music.stop()
  music.stream=null
 if ui_sound:
  ui_sound.stop()
  ui_sound.stream=null
