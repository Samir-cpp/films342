class_name PlayerGuidance
extends RefCounted
## Presentation-only recommendations: never advance time or consume simulation RNG.
static func next_step(state: Dictionary) -> Dictionary:
 if state.is_empty():return {"title":"Your career starts here","text":"Create a director to begin.","label":"Create director","action":"new"}
 if state.get("retired",false):return {"title":"Your legacy is complete","text":"Explore your filmography or load an earlier save.","label":"View filmography","action":"catalog"}
 if not state.get("pending_event",{}).is_empty():return {"title":"A decision is waiting","text":"Choose an option in the event before time can move forward.","label":"Resolve decision first","action":"event"}
 var film: Dictionary = state.get("active",{})
 if film.is_empty():return {"title":"Start your next film","text":"Give your story a title and choose a budget you can manage.","label":"Write a screenplay","action":"screenplay"}
 var stage: int = int(film.stage)
 var data: Dictionary = DataManager.config("player_guide").stages[stage].duplicate(true)
 if stage==2:
  if film.cast.is_empty() or film.crew.is_empty():
   data.text="Hire at least one performer and one crew member. Open the tabs to see both lists."
  else:
   data.label="Confirm cast & crew"
   data.action="package"
 elif stage==7:
  if int(state.week)>=int(film.release_week):
   data.label="Release in cinemas"
   data.action="release"
  else:
   data.text="Your release is %d weeks away. You can change the date in Film studio or wait."%(int(film.release_week)-int(state.week))
   data.label="Wait one week"
   data.action="week"
 return data
