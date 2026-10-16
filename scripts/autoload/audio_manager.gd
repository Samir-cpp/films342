extends Node
## Original procedural audio is baked offline to keep mobile startup light.
## Replace these resources to change the soundtrack without simulation changes.
const MUSIC: String = "res://assets/audio/calm_loop.wav"
const CLICK: String = "res://assets/audio/click.wav"
var music: AudioStreamPlayer
var ui_sound: AudioStreamPlayer
func _ready() -> void:
 if DisplayServer.get_name()=="headless" or "--silent-ui" in OS.get_cmdline_user_args():
  return
 ui_sound=AudioStreamPlayer.new()
 add_child(ui_sound)
 ui_sound.stream=load(CLICK)
 music=AudioStreamPlayer.new()
 add_child(music)
 var loop: AudioStreamWAV = load(MUSIC).duplicate()
 loop.loop_mode=AudioStreamWAV.LOOP_FORWARD
 loop.loop_end=int(loop.get_length()*loop.mix_rate)
 music.stream=loop
 music.play()
 update_volume()
func click() -> void:
 if ui_sound and GameState.settings.get("sound",true):ui_sound.play()
func update_volume() -> void:
 if music:music.volume_db=-8 if GameState.settings.get("music",true) else -80
func _exit_tree() -> void:
 if music:
  music.stop()
  music.stream=null
 if ui_sound:
  ui_sound.stop()
  ui_sound.stream=null
