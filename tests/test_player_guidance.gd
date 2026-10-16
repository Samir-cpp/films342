extends GutTest
const Guidance = preload("res://scripts/ui/player_guidance.gd")
func before_each() -> void:
 GameState.new_career({"name":"Guide Test","age":26,"district":"Dhaka","background":0,"traits":["trait_1","trait_5"]},342)
 Clock.paused=true
func test_recommendations_explain_each_production_gate() -> void:
 assert_eq(Guidance.next_step(GameState.state).action,"screenplay")
 GameState.create_film({"title":"First Film","genre":0,"tier":0,"source":0,"rating":"U"})
 var f: Dictionary = GameState.state.active
 assert_eq(Guidance.next_step(GameState.state).action,"week")
 f.stage=1
 assert_eq(Guidance.next_step(GameState.state).action,"studio")
 f.stage=2
 assert_eq(Guidance.next_step(GameState.state).action,"studio")
 f.cast=["actor_1"];f.crew=["crew_0"]
 assert_eq(Guidance.next_step(GameState.state).action,"package")
 f.stage=7;f.release_week=GameState.state.week+3
 assert_eq(Guidance.next_step(GameState.state).action,"week")
 f.release_week=GameState.state.week
 assert_eq(Guidance.next_step(GameState.state).action,"release")
 f.stage=9
 assert_eq(Guidance.next_step(GameState.state).action,"archive")
func test_guidance_is_read_only_and_pending_decisions_take_priority() -> void:
 var before := GameState.snapshot()
 for i in range(20):Guidance.next_step(GameState.state)
 assert_eq(GameState.snapshot(),before)
 GameState.state.pending_event=DataManager.rows("events")[0].duplicate(true)
 assert_eq(Guidance.next_step(GameState.state).action,"event")
func test_automatic_time_stops_at_financing_and_casting() -> void:
 GameState.create_film({"title":"First Film","genre":0,"tier":0,"source":0,"rating":"U"})
 Clock.paused=false
 GameState.next_stage()
 assert_true(Clock.paused)
 Clock.paused=false
 GameState.next_stage()
 assert_true(Clock.paused)
