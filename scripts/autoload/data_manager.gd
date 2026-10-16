extends Node
## Typed gateway for editable content. Never writes content at runtime.
var tables: Dictionary = {}
var errors: PackedStringArray = []
func _ready() -> void:
 var dir := DirAccess.open("res://data")
 for file in dir.get_files():
  if file.ends_with(".json"):
   var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/" + file))
   if parsed == null:
    errors.append("Invalid JSON: " + file)
   else:
    tables[file.get_basename()] = parsed
 for key in tables:
  if tables[key] is Array:
   var ids: Array = []
   for row in tables[key]:
    if not row is Dictionary or not row.has("id") or not row.has("name") or row.id in ids:
     errors.append("Invalid or duplicate record in " + key)
    else:
     ids.append(row.id)
 assert(errors.is_empty(), str(errors))
func rows(key: String) -> Array:
 return tables.get(key, [])
func config(key: String) -> Dictionary:
 return tables.get(key, {})
func entry(key: String, id: String) -> Dictionary:
 for row in rows(key):
  if row.id == id:
   return row
 return {}
func display_name(row: Dictionary) -> String:
 if GameState.settings.get("fictionalize", true) and row.get("real_person", false):
  var value: int = absi(str(row.get("id", "entry")).hash())
  return rows("actors")[value % rows("actors").size()].name
 return str(row.get("name", "Unknown"))
