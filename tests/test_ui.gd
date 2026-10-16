extends GutTest
func test_character_and_screenplay_buttons_use_the_visible_form() -> void:
 var scene = load("res://scenes/main.tscn").instantiate()
 add_child_autofree(scene)
 scene.selected_traits=["trait_1","trait_5"]
 scene.go("New career")
 scene.fields.name.text="Form Director"
 var begin_button: Button = find_button(scene,"Begin your career")
 assert_not_null(begin_button)
 begin_button.pressed.emit()
 await get_tree().process_frame
 assert_eq(GameState.state.director.name,"Form Director")
 assert_eq(scene.page,"Dashboard")
 scene.go("New screenplay")
 scene.fields.title.text="A Window in Dhaka"
 scene.fields.logline.text="Two strangers wait for the last bus."
 var develop_button: Button = find_button(scene,"Put it into development")
 assert_not_null(develop_button)
 develop_button.pressed.emit()
 await get_tree().process_frame
 assert_eq(GameState.state.active.title,"A Window in Dhaka")
 assert_eq(scene.page,"Film studio")
 var next: Button = find_button(scene,"Next week")
 assert_not_null(next)
 var week: int = GameState.state.week
 next.pressed.emit()
 await get_tree().process_frame
 assert_eq(GameState.state.week,week+1)
func test_name_toggle_does_not_rename_content_types() -> void:
 GameState.settings.fictionalize=true
 assert_eq(DataManager.display_name(DataManager.rows("backgrounds")[0]),"TV natok director")
 assert_eq(DataManager.display_name(DataManager.rows("genres")[0]),"Drama")
 var real := {"id":"public_test","name":"Public person","real_person":true}
 assert_ne(DataManager.display_name(real),"Public person")
 GameState.settings.fictionalize=false
 assert_eq(DataManager.display_name(real),"Public person")
 GameState.settings.fictionalize=true
func find_button(node: Node, prefix: String) -> Button:
 if node is Button and node.text.begins_with(prefix): return node
 for child in node.get_children():
  var found := find_button(child,prefix)
  if found:return found
 return null
