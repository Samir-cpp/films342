extends Node
var language: String = "en"
func text(key: String) -> String:
 var table: Dictionary = DataManager.config("localization")
 return table.get(language, {}).get(key, table.get("en", {}).get(key, key))
