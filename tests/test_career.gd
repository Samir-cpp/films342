extends GutTest
func before_each() -> void:
 Clock.paused=true
 GameState.new_career({"name":"Test Director","age":26,"district":"Dhaka","background":0,"traits":["trait_2","trait_5"],"stats":{"Vision":60,"Script":85,"Direction":85,"Leadership":40,"Business":40,"Network":20,"Charm":15,"Stamina":40,"Marketing":20}},342)
func idea(source: int = 0) -> Dictionary:
 return {"title":"The Last Ferry","logline":"A ferryman returns home.","synopsis":"A family reunion during the monsoon.","setting":"Sadarghat","genre":0,"tier":0,"source":source,"rating":"U","theme":"Family","tone":"Hopeful","era":"Present day"}
func tick() -> void:
 if not GameState.state.pending_event.is_empty():
  GameState.choose_event(0)
 GameState.advance_week()
func reach_stage(target: int) -> void:
 for i in range(150):
  if int(GameState.state.active.stage)>=target: return
  tick()
 fail_test("Failed to reach film stage %d"%target)
func fund_and_package() -> void:
 reach_stage(1)
 for attempt in range(40):
  if not GameState.state.pending_event.is_empty():GameState.choose_event(0)
  if GameState.finance("producer_10",.1,60):break
 assert_true(GameState.state.active.financed)
 for attempt in range(15):
  if GameState.hire("actors","actor_4"):break
  tick()
 for attempt in range(15):
  if GameState.hire("crew","crew_54"):break
  tick()
 assert_true(GameState.complete_packaging())
func test_character_and_creation_guards() -> void:
 assert_eq(GameState.state.week,1)
 assert_eq(GameState.state.director.name,"Test Director")
 assert_false(GameState.create_film(idea(4)),"Sequel requires a catalog")
 assert_true(GameState.create_film(idea()))
 assert_false(GameState.create_film(idea()),"Only one active production")
func test_weekly_autosave_and_five_slots() -> void:
 tick()
 assert_eq(SaveManager.read_slot(0).state.week,2.0)
 for slot in range(1,6):
  assert_eq(SaveManager.save_slot(slot),OK)
  assert_eq(SaveManager.read_slot(slot).state.director.name,"Test Director")
 assert_eq(SaveManager.save_slot(6),ERR_INVALID_PARAMETER)
func test_seeded_save_resume_matches_uninterrupted_simulation() -> void:
 GameState.create_film(idea())
 tick()
 var saved: Dictionary = GameState.snapshot()
 for i in range(8):tick()
 var expected: Dictionary = GameState.snapshot()
 GameState.restore(saved)
 for i in range(8):tick()
 assert_eq(JSON.parse_string(JSON.stringify(GameState.snapshot(),"",true,true)),JSON.parse_string(JSON.stringify(expected,"",true,true)))
func test_json_save_preserves_future_rng_and_receipts() -> void:
 GameState.create_film(idea())
 fund_and_package()
 reach_stage(7)
 GameState.state.active.release_week=GameState.state.week
 if not GameState.state.pending_event.is_empty():GameState.choose_event(0)
 GameState.begin_release()
 tick()
 assert_eq(SaveManager.save_slot(4),OK)
 for i in range(4):tick()
 var expected := GameState.snapshot()
 assert_true(SaveManager.load_slot(4))
 for i in range(4):tick()
 assert_almost_eq(float(GameState.state.active.gross),float(expected.active.gross),.000000001)
 assert_eq(GameState.snapshot().rng_state,expected.rng_state)
func test_version_one_migration_and_unknown_version() -> void:
 var old := {"version":1,"state":{"director":{},"week":1}}
 var migrated := SaveManager.migrate(old)
 assert_eq(migrated.version,2)
 assert_true(migrated.state.has("achievements"))
 assert_true(migrated.state.has("seen_events"))
func test_event_choice_applies_once_and_blocks_clock() -> void:
 GameState.create_film(idea())
 GameState.state.pending_event=DataManager.rows("events")[10].duplicate(true)
 var before: float = GameState.state.cash
 var week: int = GameState.state.week
 GameState.advance_week()
 assert_eq(GameState.state.week,week)
 var delta: float = GameState.state.pending_event.choices[0].cash
 GameState.choose_event(0)
 assert_almost_eq(GameState.state.cash,before+delta,.001)
 GameState.choose_event(0)
 assert_almost_eq(GameState.state.cash,before+delta,.001)
func test_full_film_rights_awards_catalog_and_sequel() -> void:
 assert_true(GameState.create_film(idea()))
 fund_and_package()
 GameState.state.active.post_plan=2
 reach_stage(7)
 if not GameState.state.pending_event.is_empty():GameState.choose_event(0)
 var f: Dictionary = GameState.state.active
 f.release_week=GameState.state.week
 var price: float = GameState.sell_rights("ott_platforms","ott_0")
 assert_gt(price,0.0)
 assert_eq(GameState.sell_rights("ott_platforms","ott_1"),0.0,"OTT license is exclusive")
 assert_gt(GameState.sell_rights("tv_channels","tv_0"),0.0)
 assert_gt(GameState.sell_rights("music_labels","label_0"),0.0)
 for market in DataManager.rows("overseas_markets"):
  assert_gt(GameState.sell_rights("overseas_markets",market.id),0.0)
 assert_true(GameState.begin_release())
 reach_stage(9)
 assert_eq(f.history.size(),8)
 assert_gt(f.gross,0.0)
 assert_gt(f.receipts,0.0)
 assert_true("First release" in GameState.state.achievements)
 GameState.campaign("award_0")
 assert_true("award_0" in f.awards)
 assert_true("Award winner" in GameState.state.achievements,"Seed 342 should win with this crew and script")
 GameState.archive_film()
 assert_eq(GameState.state.films.size(),1)
 assert_true(GameState.state.active.is_empty())
 var catalog: Dictionary = GameState.state.films[0]
 var before: float = catalog.catalog_income
 for i in range(20):tick()
 assert_gt(catalog.catalog_income,before)
 assert_true(catalog.rights["tv_channelstv_0"].paid)
 assert_true(GameState.rerelease(0))
 assert_true(GameState.create_film(idea(4)))
 assert_gt(GameState.state.active.hype,8.0)
 assert_eq(SaveManager.save_slot(5),OK)
 var expected := GameState.snapshot()
 assert_true(SaveManager.load_slot(5))
 assert_eq(JSON.parse_string(JSON.stringify(GameState.snapshot(),"",true,true)),JSON.parse_string(JSON.stringify(expected,"",true,true)))
 fund_and_package()
 reach_stage(7)
 if not GameState.state.pending_event.is_empty():GameState.choose_event(0)
 GameState.state.active.release_week=GameState.state.week
 assert_true(GameState.begin_release())
 reach_stage(9)
 assert_true("Chapter two" in GameState.state.achievements)
 GameState.archive_film()
 assert_eq(GameState.state.films.size(),2)
func test_self_funding_and_no_duplicate_hiring() -> void:
 GameState.create_film(idea())
 reach_stage(1)
 assert_true(GameState.self_finance())
 for i in range(20):
  if GameState.hire("actors","actor_0"):break
  tick()
 var before: float = GameState.state.active.spent
 assert_false(GameState.hire("actors","actor_0"))
 assert_eq(GameState.state.active.spent,before)
func test_loan_limit_and_paid_recovery() -> void:
 for i in range(3):assert_true(GameState.career_action("loan"))
 assert_false(GameState.career_action("loan"))
 var before: float = GameState.state.cash
 assert_true(GameState.career_action("work"))
 assert_gt(GameState.state.cash,before)
func test_delayed_backend_does_not_pay_a_loss() -> void:
 GameState.create_film(idea())
 var f: Dictionary = GameState.state.active
 f.stage=9;f.financed=true;f.spent=100;f.receipts=0;f.catalog_income=0
 f.rights={"test":{"buyer":"Test","price":20,"due":1,"paid":false,"category":"tv_channels"}}
 var before: float = GameState.state.cash
 GameState.collect_rights()
 assert_eq(GameState.state.cash,before)
 assert_eq(f.receipts,20.0)
 GameState.collect_rights()
 assert_eq(f.receipts,20.0)
func test_corrupt_and_future_saves_are_rejected() -> void:
 assert_false(SaveManager.valid_state({"director":[],"stats":{}}))
 var saved := GameState.snapshot()
 assert_true(SaveManager.valid_state(saved))
 var file := FileAccess.open(SaveManager.path_for(3),FileAccess.WRITE)
 file.store_string(JSON.stringify({"version":999,"state":saved}))
 file.close()
 assert_true(SaveManager.read_slot(3).is_empty())
 file=FileAccess.open(SaveManager.path_for(3),FileAccess.WRITE)
 file.store_string("{broken")
 file.close()
 assert_false(SaveManager.load_slot(3))
func test_retirement_freezes_time() -> void:
 assert_true(GameState.career_action("retire"))
 var week: int = GameState.state.week
 GameState.advance_week()
 assert_eq(GameState.state.week,week)
