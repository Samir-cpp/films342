extends GutTest
var original_scale: Vector2i
var original_font: int
var original_zoom: float
func before_each() -> void:
 original_scale=get_tree().root.content_scale_size
 original_font=int(GameState.settings.font_size)
 original_zoom=float(GameState.settings.ui_scale)
 GameState.settings.font_size=18
 GameState.new_career({"name":"Mobile Test","age":26,"district":"Dhaka","background":0,"traits":["trait_1","trait_5"]},342)
 Clock.paused=true
func after_each() -> void:
 GameState.settings.font_size=original_font
 GameState.settings.ui_scale=original_zoom
 get_tree().root.content_scale_factor=original_zoom
 get_tree().root.content_scale_size=original_scale
 await get_tree().process_frame
func test_portrait_layout_keeps_primary_controls_on_screen() -> void:
 get_tree().root.content_scale_size=Vector2i(360,800)
 var scene = load("res://scenes/main.tscn").instantiate()
 add_child_autofree(scene)
 await get_tree().process_frame
 for screen in ["Main menu","Dashboard","New career","New screenplay","How to play","Save manager","Settings"]:
  scene.go(screen)
  await get_tree().process_frame
  await get_tree().process_frame
  assert_true(scene.compact,screen)
  assert_true(scene.portrait,screen)
  check_widths(scene,get_tree().root.get_visible_rect().size.x,screen)
func check_widths(node: Node, width: float, screen: String) -> void:
 if node is Control and node.is_visible_in_tree() and not node is Window:
  assert_lte(node.global_position.x+node.size.x,width+2,"%s: %s stays within the viewport"%[screen,node.name])
  if node is Button and not node is CheckBox:
   assert_gte(node.size.y,48.0,"Touch target: "+node.text)
 for child in node.get_children():
  if not child is Window:check_widths(child,width,screen)
func test_rotation_preserves_unsubmitted_screenplay() -> void:
 get_tree().root.content_scale_size=Vector2i(360,800)
 var scene = load("res://scenes/main.tscn").instantiate()
 add_child_autofree(scene)
 scene.go("New screenplay")
 scene.fields.title.text="Do not lose my story"
 scene.fields.synopsis.text="A draft written on the train."
 scene.fields.genre.select(3)
 get_tree().root.content_scale_size=Vector2i(900,420)
 await get_tree().process_frame
 await get_tree().process_frame
 assert_eq(scene.fields.title.text,"Do not lose my story")
 assert_eq(scene.fields.synopsis.text,"A draft written on the train.")
 assert_eq(scene.fields.genre.selected,3)
 assert_true(scene.compact)
 assert_false(scene.portrait)
func test_app_background_saves_and_pauses_the_career() -> void:
 var scene = load("res://scenes/main.tscn").instantiate()
 add_child_autofree(scene)
 Clock.paused=false
 scene._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
 assert_true(Clock.paused)
 assert_eq(SaveManager.read_slot(0).state.director.name,"Mobile Test")
func test_quick_start_uses_a_valid_point_buy_and_saves() -> void:
 var scene = load("res://scenes/main.tscn").instantiate()
 add_child_autofree(scene)
 scene.quick_start()
 var dialog: AcceptDialog
 for child in scene.get_children():
  if child is AcceptDialog:dialog=child
 assert_not_null(dialog)
 dialog.confirmed.emit()
 await get_tree().process_frame
 assert_eq(scene.page,"Dashboard")
 assert_eq(GameState.state.director.traits.size(),2)
 var total: int = 0
 for stat in GameState.state.director.stats:total+=int(GameState.state.director.stats[stat])
 assert_eq(total,405)
 assert_eq(SaveManager.read_slot(0).state.director.name,GameState.state.director.name)

func test_every_film_stage_fits_portrait_and_landscape() -> void:
 var scene = load("res://scenes/main.tscn").instantiate()
 add_child_autofree(scene)
 GameState.create_film({"title":"Mobile Premiere","logline":"A new beginning.","synopsis":"A story.","setting":"Dhaka","genre":0,"tier":0,"source":0,"rating":"U","theme":"Family","tone":"Hopeful","era":"Present day"})
 for viewport_size in [Vector2i(360,800),Vector2i(900,420)]:
  get_tree().root.content_scale_size=viewport_size
  for stage in range(10):
   var film: Dictionary = GameState.state.active
   film.stage=stage
   film.quality=60
   film.director_income=10
   film.profit=15
   film.opening=.4
   scene.go("Film studio")
   await get_tree().process_frame
   await get_tree().process_frame
   check_widths(scene,get_tree().root.get_visible_rect().size.x,"Stage %d / %s"%[stage,str(viewport_size)])
 GameState.state.pending_event=DataManager.rows("events")[0].duplicate(true)
 scene.render()
 await get_tree().process_frame
 await get_tree().process_frame
 check_widths(scene,get_tree().root.get_visible_rect().size.x,"Event overlay")
func test_casting_role_search_and_tab_survive_refresh() -> void:
 var scene = load("res://scenes/main.tscn").instantiate()
 add_child_autofree(scene)
 GameState.create_film({"title":"Casting Test","genre":0,"tier":0,"source":0,"rating":"U"})
 GameState.state.active.stage=2
 scene.go("Film studio")
 var tabs: TabContainer = find_tabs(scene)
 tabs.current_tab=3
 var search: LineEdit = tabs.get_child(3).get_child(0)
 search.text="DOP"
 search.text_changed.emit("DOP")
 assert_eq(scene.board_state.casting_tab,3)
 assert_eq(scene.board_state.crew_search,"DOP")
 scene.render()
 await get_tree().process_frame
 tabs=find_tabs(scene)
 assert_eq(tabs.current_tab,3)
 search=tabs.get_child(3).get_child(0)
 assert_eq(search.text,"DOP")
 var rows: VBoxContainer = tabs.get_child(3).get_child(1).get_child(2) if tabs.get_child(3).get_child(1).get_child_count()>2 else tabs.get_child(3).get_child(1).get_child(0)
 var visible_count: int = 0
 for row in rows.get_children():
  if row.visible:
   assert_true("dop" in str(row.get_meta("search","")))
   visible_count+=1
 assert_gt(visible_count,0)
func find_tabs(node: Node) -> TabContainer:
 if node is TabContainer:return node
 for child in node.get_children():
  var found: TabContainer = find_tabs(child)
  if found:return found
 return null

func test_large_text_and_zoom_remain_accessible_on_a_phone() -> void:
 GameState.settings.font_size=24
 GameState.settings.ui_scale=1.2
 get_tree().root.content_scale_size=Vector2i(360,800)
 var scene = load("res://scenes/main.tscn").instantiate()
 add_child_autofree(scene)
 for screen in ["Main menu","Dashboard","New career","Settings"]:
  scene.go(screen)
  await get_tree().process_frame
  await get_tree().process_frame
  check_widths(scene,get_tree().root.get_visible_rect().size.x,"Large text "+screen)

func test_keyboard_resize_keeps_the_name_dialog_alive() -> void:
 var scene = load("res://scenes/main.tscn").instantiate()
 add_child_autofree(scene)
 scene.quick_start()
 var dialog: AcceptDialog
 for child in scene.get_children():
  if child is AcceptDialog:dialog=child
 scene.viewport_changed()
 await get_tree().process_frame
 await get_tree().process_frame
 assert_true(is_instance_valid(dialog))
 assert_true(dialog.visible)
func test_keyboard_resize_keeps_the_focused_draft_editor() -> void:
 var scene = load("res://scenes/main.tscn").instantiate()
 add_child_autofree(scene)
 scene.go("New screenplay")
 var editor: LineEdit = scene.fields.title
 editor.text="Still typing"
 editor.grab_focus()
 scene.viewport_changed()
 await get_tree().process_frame
 await get_tree().process_frame
 assert_true(is_instance_valid(editor))
 assert_eq(editor.text,"Still typing")
 assert_eq(scene.fields.title,editor)
