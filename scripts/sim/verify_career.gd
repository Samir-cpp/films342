class_name CareerVerification
extends RefCounted
## Exercises the exported game's actual API, JSON content and save system.
## Invoke explicitly with --verify-career and an isolated user-data directory.
static func resolve_event() -> void:
 if not GameState.state.pending_event.is_empty():GameState.choose_event(0)
static func reach(target: int) -> bool:
 for i in range(150):
  resolve_event()
  if int(GameState.state.active.stage)>=target:return true
  GameState.advance_week()
 return false
static func run() -> bool:
 GameState.new_career({"name":"Export Verification","age":26,"district":"Dhaka","background":0,"traits":["trait_2","trait_5"],"stats":{"Vision":60,"Script":85,"Direction":85,"Leadership":40,"Business":40,"Network":20,"Charm":15,"Stamina":40,"Marketing":20}},342)
 for chapter in range(2):
  if not GameState.create_film({"title":"The Last Ferry"+(" II" if chapter else ""),"logline":"A journey home.","synopsis":"A river reunites two generations.","setting":"Sadarghat","genre":0,"tier":0,"source":4 if chapter else 0,"rating":"U","theme":"Family","tone":"Hopeful","era":"Present day"}):return false
  if not reach(1):return false
  var funded: bool = false
  for attempt in range(40):
   resolve_event()
   if GameState.finance("producer_10",.1,60):
    funded=true
    break
  if not funded:return false
  for table_id in [["actors","actor_4"],["crew","crew_54"]]:
   var hired: bool = false
   for attempt in range(20):
    resolve_event()
    if GameState.hire(table_id[0],table_id[1]):
     hired=true
     break
    GameState.advance_week()
   if not hired:return false
  if not GameState.complete_packaging():return false
  GameState.state.active.post_plan=2
  if not reach(7):return false
  resolve_event()
  GameState.state.active.release_week=GameState.state.week
  if GameState.sell_rights("ott_platforms","ott_0")<=0:return false
  if GameState.sell_rights("tv_channels","tv_0")<=0:return false
  if GameState.sell_rights("music_labels","label_0")<=0:return false
  if not GameState.begin_release():return false
  if not reach(9):return false
  var film: Dictionary = GameState.state.active
  if film.history.size()!=8 or film.gross<=0:return false
  GameState.campaign("award_0")
  print("VERIFIED_FILM: %s · quality %.1f · gross %.1f · producer profit %.1f"%[film.title,film.quality,film.gross,film.profit])
  GameState.archive_film()
 if not "Award winner" in GameState.state.achievements:return false
 if not "Chapter two" in GameState.state.achievements:return false
 for i in range(20):
  resolve_event()
  GameState.advance_week()
 if GameState.state.films[0].catalog_income<=0:return false
 if SaveManager.save_slot(5)!=OK:return false
 var saved_rng: String = GameState.snapshot().rng_state
 if not SaveManager.load_slot(5):return false
 if GameState.snapshot().rng_state!=saved_rng:return false
 if GameState.state.films.size()!=2:return false
 print("CAREER_VERIFICATION_OK: two releases, exclusive licenses, award win, royalties, sequel and JSON reload")
 return true
