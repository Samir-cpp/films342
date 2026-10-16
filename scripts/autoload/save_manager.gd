extends Node
const VERSION: int = 2
const DIRECTORY: String = "user://saves"
func path_for(slot: int) -> String:
 return DIRECTORY + "/" + ("autosave" if slot==0 else "slot_%d"%slot) + ".json"
func save_slot(slot: int) -> Error:
 if slot<0 or slot>5 or GameState.state.is_empty():
  return ERR_INVALID_PARAMETER
 DirAccess.make_dir_recursive_absolute(DIRECTORY)
 var path := path_for(slot)
 var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
 if file==null:
  return FileAccess.get_open_error()
 file.store_string(JSON.stringify({"version":VERSION,"state":GameState.snapshot(),"settings":GameState.settings},"\t",true,true))
 file.flush()
 var error: Error = file.get_error()
 file.close()
 if error != OK:
  return error
 if FileAccess.file_exists(path):
  DirAccess.copy_absolute(path,path+".bak")
 return DirAccess.rename_absolute(path+".tmp",path)
func migrate(data: Dictionary) -> Dictionary:
 if int(data.get("version",0))==1:
  data.state["achievements"]=data.state.get("achievements",[])
  data.state["seen_events"]=data.state.get("seen_events",[])
  data["version"]=2
 return data
func read_slot(slot: int) -> Dictionary:
 if slot<0 or slot>5 or not FileAccess.file_exists(path_for(slot)):
  return {}
 var parser := JSON.new()
 if parser.parse(FileAccess.get_file_as_string(path_for(slot)))!=OK:
  return {}
 var parsed = parser.data
 if not parsed is Dictionary:
  return {}
 var data: Dictionary = migrate(parsed)
 if int(data.get("version",0))!=VERSION or not data.get("state") is Dictionary:
  return {}
 for key in ["director","week","cash","stats","films","rng_state","active","relationships","inbox","pending_event","achievements","seen_events","retired"]:
  if not data.state.has(key):
   return {}
 if not valid_state(data.state):
  return {}
 return data
func valid_state(saved: Dictionary) -> bool:
 for key in ["director","stats","active","relationships","pending_event"]:
  if not saved.get(key) is Dictionary: return false
 for key in ["films","inbox","achievements","seen_events"]:
  if not saved.get(key) is Array: return false
 if not saved.director.get("name") is String or not saved.director.get("age") is float and not saved.director.get("age") is int:
  return false
 if not saved.get("rng_state") is String or not str(saved.rng_state).is_valid_int(): return false
 for key in ["week","cash","debt","industry","critics","audience","stress"]:
  if not saved.get(key) is float and not saved.get(key) is int: return false
 if saved.week<1: return false
 for key in DataManager.config("economy").stats:
  if not saved.stats.get(key) is float and not saved.stats.get(key) is int: return false
 var films: Array = saved.films.duplicate()
 if not saved.active.is_empty():films.append(saved.active)
 for film in films:
  if not film is Dictionary: return false
  for key in ["stage","progress","title","tier","genre","script","quality","spent","receipts","cast","crew","rights","history"]:
   if not film.has(key): return false
  if not film.title is String or not film.rights is Dictionary or not film.history is Array: return false
  if int(film.stage)<0 or int(film.stage)>9: return false
 return true
func load_slot(slot: int) -> bool:
 var data := read_slot(slot)
 if data.is_empty():
  return false
 GameState.restore(data.state)
 GameState.settings.merge(data.get("settings",{}),true)
 Localization.language=GameState.settings.get("language","en")
 Clock.paused=true
 EventBus.changed.emit()
 return true
func label_for(slot: int) -> String:
 var data := read_slot(slot)
 if data.is_empty():
  return "Empty / incompatible"
 return "%s · Week %d · ৳%.1f lakh"%[data.state.director.name,data.state.week,data.state.cash]
func save_settings() -> void:
 var file := FileAccess.open("user://settings.json",FileAccess.WRITE)
 if file:
  file.store_string(JSON.stringify(GameState.settings))
