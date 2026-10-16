extends GutTest
func before_each() -> void:
 GameState.new_career({"name":"PC Director","age":26,"district":"Dhaka","background":0,"traits":["trait_1","trait_5"]},342)
 Clock.paused=true
func key(code: int, control: bool = false) -> InputEventKey:
 var event := InputEventKey.new()
 event.keycode=code
 event.pressed=true
 event.ctrl_pressed=control
 return event
func test_desktop_shortcuts_navigate_and_save() -> void:
 var scene = load("res://scenes/main.tscn").instantiate()
 add_child_autofree(scene)
 scene._unhandled_key_input(key(KEY_2))
 assert_eq(scene.page,"Film studio")
 scene._unhandled_key_input(key(KEY_3))
 assert_eq(scene.page,"Release calendar")
 scene._unhandled_key_input(key(KEY_F1))
 assert_eq(scene.page,"How to play")
 scene._unhandled_key_input(key(KEY_S,true))
 assert_eq(SaveManager.read_slot(0).state.director.name,"PC Director")
func test_typing_and_dialogs_block_gameplay_shortcuts() -> void:
 var scene = load("res://scenes/main.tscn").instantiate()
 add_child_autofree(scene)
 scene.go("New screenplay")
 scene.fields.title.grab_focus()
 var week: int = GameState.state.week
 scene._unhandled_key_input(key(KEY_N))
 scene._unhandled_key_input(key(KEY_1))
 assert_eq(GameState.state.week,week)
 assert_eq(scene.page,"New screenplay")
 scene.fields.title.release_focus()
 scene.quick_start()
 scene._unhandled_key_input(key(KEY_N))
 scene._unhandled_key_input(key(KEY_2))
 assert_eq(GameState.state.week,week)
 assert_eq(scene.page,"New screenplay")
