extends Node
const Economy = preload("res://scripts/sim/economy.gd")
var state: Dictionary = {}
var rng := RandomNumberGenerator.new()
var settings: Dictionary = {"fictionalize":true,"music":true,"sound":true,"ui_scale":1.0,"font_size":16,"language":"en"}
func _ready() -> void:
 if FileAccess.file_exists("user://settings.json"):
  var loaded = JSON.parse_string(FileAccess.get_file_as_string("user://settings.json"))
  if loaded is Dictionary:
   settings.merge(loaded,true)
 Localization.language=settings.language
func config() -> Dictionary:
 return DataManager.config("economy")
func new_career(profile: Dictionary, seed_value: int = 342) -> void:
 rng.seed=seed_value
 var background: Dictionary = DataManager.rows("backgrounds")[int(profile.get("background",0))]
 var stats: Dictionary = {}
 for key in config().stats:
  stats[key]=int(profile.get("stats",{}).get(key,40))
 stats[background.bonus_stat]=mini(100,stats[background.bonus_stat]+int(background.bonus))
 for id in profile.get("traits",[]):
  var trait_data: Dictionary = DataManager.entry("traits",id)
  if not trait_data.is_empty():
   stats[trait_data.stat]=mini(100,stats[trait_data.stat]+int(trait_data.bonus))
 state={"director":profile.duplicate(true),"week":1,"cash":background.cash,"debt":background.debt,"industry":15.0,"critics":10.0,"audience":10.0,"stress":10.0,"stats":stats,"active":{},"films":[],"inbox":[],"relationships":{},"rivals":[],"pending_event":{},"seen_events":[],"achievements":[],"retired":false,"house":false,"rng_state":str(rng.state)}
 for i in range(int(background.contacts)):
  state.relationships[DataManager.rows("producers")[i].id]=5.0
 log_message(background.problem)
 log_message("Welcome to Dhallywood. All financial figures are editable estimates in lakh BDT.")
 generate_rivals()
 EventBus.changed.emit()
func snapshot() -> Dictionary:
 state.rng_state=str(rng.state)
 return state.duplicate(true)
func restore(saved: Dictionary) -> void:
 state=saved.duplicate(true)
 var films: Array = state.films.duplicate()
 if not state.active.is_empty():films.append(state.active)
 for f in films:
  if not f.has("unavailable"):f.unavailable={}
  if not f.has("award_results"):f.award_results={}
 rng.state=int(state.rng_state)
func log_message(message: String) -> void:
 state.inbox.push_front({"week":state.week,"text":message})
 if state.inbox.size()>100:
  state.inbox.resize(100)
 EventBus.notice.emit(message)
func date_text() -> String:
 return "%d · Week %02d"%[int(config().starting_year)+int((int(state.week)-1)/52), (int(state.week)-1)%52+1]
func holiday_at(week: int) -> Dictionary:
 for holiday in DataManager.rows("holidays"):
  if abs((week-1)%52+1-int(holiday.week))<=1:
   return holiday
 return {"name":"Regular season","multiplier":1.0}
func generate_rivals() -> void:
 var titles: Array = DataManager.config("content").rival_titles
 for i in range(4):
  state.rivals.append({"title":titles[rng.randi_range(0,titles.size()-1)],"week":int(state.week)+i*3+rng.randi_range(1,3),"strength":rng.randf_range(.12,.45),"gross":rng.randf_range(25,450)})
 if state.rivals.size()>40:
  state.rivals=state.rivals.slice(-40)
func create_film(idea: Dictionary) -> bool:
 if state.is_empty() or not state.active.is_empty() or state.retired:
  return false
 if str(idea.get("title","")).strip_edges().is_empty():
  return false
 var source: int = int(idea.get("source",0))
 if source>=4 and state.films.is_empty():
  return false
 var tier: Dictionary = config().tiers[int(idea.get("tier",0))]
 var film: Dictionary = idea.duplicate(true)
 film.merge({"id":"film_%d"%state.week,"stage":0,"progress":0,"stage_total":3,"script":0.0,"quality":0.0,"hype":8.0,"budget":float(tier.budget),"spent":0.0,"receipts":0.0,"gross":0.0,"history":[],"cast":[],"crew":[],"star":25.0,"crew_skill":40.0,"financed":false,"self_financed":false,"backend":.10,"fee":config().base_fee,"rights":{},"advance_remaining":0.0,"release_week":int(state.week)+20,"screens":int(tier.screens),"rating":idea.get("rating","U"),"risk":.12,"awards":[],"award_results":{},"unavailable":{},"catalog_income":0.0,"last_catalog_week":0,"archived":false,"production_strategy":0,"marketing_spend":0.0,"plan":0,"post_plan":0,"writer":0.0,"control":100,"overrun":false},true)
 if source==1:
  film.script=45
  film.writer=60
  charge_film(film,8)
 elif source==2 or source==3:
  charge_film(film,12)
 elif source>=4:
  film.hype+=15
  film.script=state.films.back().script*.2
 state.active=film
 log_message("Development begins: "+film.title)
 EventBus.changed.emit()
 return true
func charge_film(film: Dictionary, amount: float) -> void:
 amount=maxf(0,amount)
 film.spent+=amount
 if film.self_financed or not film.financed:
  state.cash-=amount
func finance(producer_id: String, backend: float, creative_control: int) -> bool:
 var f: Dictionary = state.active
 if f.is_empty() or int(f.stage)!=1 or f.financed:
  return false
 var producer: Dictionary = DataManager.entry("producers",producer_id)
 if producer.is_empty():
  return false
 var relationship: float = state.relationships.get(producer_id,0)
 var chance: float = Economy.pitch_chance(state.stats.Business,state.industry+relationship,f.budget,float(producer.budget_range[1]),config().pitch_base)
 chance-=maxf(0,backend-.1)*.8+maxf(0,creative_control-60)*.003
 if rng.randf()>chance:
  state.relationships[producer_id]=relationship-2
  log_message("Pitch declined by %s. Revise the proposal or self-finance."%DataManager.display_name(producer))
  state.stats.Business=minf(100,state.stats.Business+1)
  f.progress=0
  advance_week()
  return false
 f.financed=true
 f.backend=backend
 f.control=creative_control
 f.producer=producer_id
 state.cash+=f.fee
 state.relationships[producer_id]=relationship+5
 log_message("Financing secured. Director fee ৳%.1f lakh; %.0f%% backend."%[f.fee,backend*100])
 next_stage()
 EventBus.changed.emit()
 return true
func self_finance() -> bool:
 var f: Dictionary = state.active
 if f.is_empty() or int(f.stage)!=1 or state.cash<f.budget-f.spent:
  return false
 f.financed=true
 f.self_financed=true
 f.backend=1.0
 f.fee=0
 next_stage()
 EventBus.changed.emit()
 return true
func hire(table: String, id: String) -> bool:
 var f: Dictionary = state.active
 if f.is_empty() or int(f.stage)!=2:
  return false
 var person: Dictionary = DataManager.entry(table,id)
 var key: String = "crew" if table=="crew" else "cast"
 if person.is_empty() or id in f[key] or f[key].size()>=(12 if key=="crew" else 3):
  return false
 if int(f.get("unavailable",{}).get(id,0))==int(state.week):
  return false
 if rng.randf()>float(person.availability):
  f.unavailable[id]=int(state.week)
  log_message(DataManager.display_name(person)+" is unavailable this week.")
  EventBus.changed.emit()
  return false
 var fee: float = float(person.fee_range[0])
 if f.spent+fee>f.budget*1.5:
  return false
 f[key].append(id)
 charge_film(f,fee)
 if key=="cast":
  f.star=maxf(f.star,float(person.tier)*18)
 else:
  var total: float = 0
  for crew_id in f.crew:
   total+=DataManager.entry("crew",crew_id).skill
  f.crew_skill=total/f.crew.size()
 state.relationships[id]=float(state.relationships.get(id,0))+3
 EventBus.changed.emit()
 return true
func next_stage() -> void:
 var f: Dictionary = state.active
 f.stage=int(f.stage)+1
 f.progress=0
 f.stage_total=int(DataManager.config("content").stage_weeks[int(f.stage)])
 if int(f.stage)==4:
  var base: Dictionary = config().tiers[int(f.tier)]
  f.stage_total=maxi(2,int(ceil(float(base.days)/6)))
 if int(f.stage)==8:
  f.release_week=int(state.week)
  for key in f.rights:
   var deal: Dictionary = f.rights[key]
   var buyer_id: String = key.trim_prefix(deal.category)
   deal.due=int(state.week)+int(DataManager.entry(deal.category,buyer_id).get("window",0))
  f.review=""
  for review in DataManager.rows("reviews"):
   if f.quality>=review.min_quality: f.review=review.text
  log_message("Critics on %s: %s"%[f.title,f.review])
  f.opening=Economy.opening_occupancy(f.star,f.hype,f.quality,holiday_at(state.week).multiplier,competition_at(state.week),config())
  EventBus.film_released.emit(f.title)
 log_message("%s → %s"%[f.title,DataManager.config("content").stage_labels[int(f.stage)]])
func complete_packaging() -> bool:
 if state.active.is_empty() or int(state.active.stage)!=2 or state.active.cast.is_empty() or state.active.crew.is_empty():
  return false
 next_stage()
 EventBus.changed.emit()
 return true
func begin_release() -> bool:
 if state.active.is_empty() or int(state.active.stage)!=7 or int(state.week)<int(state.active.release_week):
  return false
 next_stage()
 EventBus.changed.emit()
 return true
func competition_at(week: int) -> float:
 var result: float = 0
 for rival in state.rivals:
  if abs(int(rival.week)-week)<3:
   result+=float(rival.strength)
 return result
func sell_rights(category: String, id: String) -> float:
 var f: Dictionary = state.active
 if f.is_empty() or int(f.stage)<7 or f.rights.has(category+id):
  return 0
 if category!="overseas_markets":
  for key in f.rights:
   if f.rights[key].category==category:
    return 0
 var buyer: Dictionary = DataManager.entry(category,id)
 if buyer.is_empty():
  return 0
 var price: float = Economy.rights_price(f.quality,f.hype,float(buyer.price_range[0]),config())
 price=minf(price,float(buyer.price_range[1]))
 var window: int = int(buyer.get("window",0))
 f.rights[category+id]={"buyer":DataManager.display_name(buyer),"price":price,"due":int(f.release_week)+window,"paid":false,"category":category}
 log_message("%s license signed: ৳%.1f lakh, payable after week %d."%[DataManager.display_name(buyer),price,int(f.release_week)+window])
 EventBus.changed.emit()
 return price
func choose_event(index: int) -> void:
 var event: Dictionary = state.pending_event
 if event.is_empty() or index<0 or index>=event.choices.size():
  return
 var choice: Dictionary = event.choices[index]
 state.cash+=float(choice.cash)
 state.stress=clampf(state.stress+float(choice.stress),0,100)
 if not state.active.is_empty():
  state.active.quality=clampf(state.active.quality+float(choice.quality),0,100)
  state.active.hype=clampf(state.active.hype+float(choice.hype),0,100)
  state.active.script=clampf(state.active.script+float(choice.quality)*.5,0,100)
  if state.active.has("producer"):
   var id: String = state.active.producer
   state.relationships[id]=float(state.relationships.get(id,0))+float(choice.relationship)
 state.pending_event={}
 log_message(event.name+": "+choice.label)
 SaveManager.save_slot(0)
 EventBus.changed.emit()
func advance_week() -> void:
 if state.is_empty() or state.retired or not state.pending_event.is_empty():
  return
 state.week=int(state.week)+1
 state.cash-=Economy.interest(state.debt,config().loan_interest)
 if int(state.week)%52==1:
  state.director.age=int(state.director.age)+1
  state.stats.Stamina=maxf(10,state.stats.Stamina-1)
  state.stats.Network=minf(100,state.stats.Network+1)
 if int(state.week)%13==1:
  generate_rivals()
 var f: Dictionary = state.active
 if not f.is_empty() and int(f.stage)<9:
  var stage: int = int(f.stage)
  f.progress=int(f.progress)+1
  match stage:
   0:
    charge_film(f,1.5)
    f.script=Economy.script_quality(state.stats,int(f.progress),float(DataManager.rows("genres")[int(f.genre)].trend),f.writer)
    if f.progress>=f.stage_total:
     next_stage()
   3:
    charge_film(f,2.0+float(f.plan))
    var location: Dictionary = DataManager.rows("locations")[int(f.get("location",0))]
    f.risk=clampf(.12+float(location.risk)-float(f.plan)*.06-state.stats.Leadership*.001,0,.4)
    if f.progress==1: charge_film(f,float(location.cost)+float(location.permit))
    if f.progress>=f.stage_total:
     next_stage()
   4:
    var tier: Dictionary = config().tiers[int(f.tier)]
    var factor: float = 1
    for id in state.director.traits:
     factor*=float(DataManager.entry("traits",id).cost_factor)
    var days: float = minf(6,float(tier.days)-(int(f.progress)-1)*6)
    var cost: float = Economy.production_cost(days,float(tier.daily_cost),float(f.risk),factor)
    if int(f.production_strategy)==1:
     cost*=.82
     f.script=maxf(5,f.script-2)
    elif int(f.production_strategy)==2:
     cost*=1.25
     f.script=minf(100,f.script+2)
    charge_film(f,cost)
    state.stress=clampf(state.stress+8+(50-state.stats.Stamina)*.06,0,100)
    if f.progress>=f.stage_total:
     f.quality=Economy.quality(f.script,state.stats.Direction,f.star,f.crew_skill,config())-maxf(0,state.stress-65)*.15
     next_stage()
   5:
    charge_film(f,3+float(f.post_plan)*2)
    f.quality=clampf(f.quality+float(f.post_plan)+.5,0,100)
    if f.progress>=f.stage_total:
     if f.rating=="18+":
      f.quality=maxf(1,f.quality-4)
      log_message("Censor review complete: restricted certificate; edits reduced quality by 4.")
     next_stage()
   6:
    charge_film(f,float(f.marketing_spend))
    f.hype=clampf(f.hype+state.stats.Marketing*.12+sqrt(maxf(0,float(f.marketing_spend)))*3,0,100)
    if f.progress>=f.stage_total:
     next_stage()
   8:
    var week: int = int(f.progress)
    var gross: float = Economy.weekly_gross(int(float(f.screens)*(.75 if f.rating=="18+" else 1.0)),float(f.opening),week,f.quality,float(config().piracy),config())
    var receipts: Dictionary = Economy.producer_receipts(gross,week,f.star,f.advance_remaining,config())
    f.advance_remaining=receipts.advance_remaining
    f.gross+=gross
    f.receipts+=receipts.income
    f.history.append({"week":week,"gross":gross,"receipts":receipts.income})
    log_message("%s · theatrical week %d: gross ৳%.1f lakh, receipts ৳%.1f lakh."%[f.title,week,gross,receipts.income])
    if week>=int(config().max_run):
     finish_film()
  if f.spent>f.budget and not f.overrun:
   f.overrun=true
   log_message("Budget overrun: renegotiate scope. Your backer and reputation bear the risk.")
   state.industry=maxf(0,state.industry-3)
  if int(f.stage)<8 and rng.randf()<.28:
   var eligible: Array = []
   var stage_name: String = DataManager.config("content").stages[int(f.stage)]
   for event in DataManager.rows("events"):
    if event.conditions.stage==stage_name and int(event.conditions.min_week)<=int(state.week) and not event.id in state.seen_events:
     eligible.append(event)
   if not eligible.is_empty():
    state.pending_event=eligible[rng.randi_range(0,eligible.size()-1)].duplicate(true)
    state.seen_events.append(state.pending_event.id)
    Clock.paused=true
 collect_rights()
 if int(state.week)%4==0:
  catalog_tick()
 state.stress=maxf(0,state.stress-2)
 if state.cash<config().minimum_cash:
  Clock.paused=true
  log_message("Cash is critically low. Take paid work, arrange a loan, or repay debt after a release.")
 SaveManager.save_slot(0)
 EventBus.week_passed.emit(int(state.week))
 EventBus.changed.emit()
func collect_rights() -> void:
 var all_films: Array = state.films.duplicate()
 if not state.active.is_empty():
  all_films.append(state.active)
 for film in all_films:
  for key in film.rights:
   var deal: Dictionary = film.rights[key]
   if not deal.paid and int(state.week)>=int(deal.due) and int(film.stage)>=8:
    deal.paid=true
    var previous_receipts: float = float(film.receipts)
    film.receipts+=float(deal.price)
    if int(film.stage)==9:
     var income: float = float(deal.price) if film.self_financed else Economy.director_profit(film.receipts,film.spent,film.backend,0)-Economy.director_profit(previous_receipts,film.spent,film.backend,0)
     state.cash+=income
     film.catalog_income+=income
     film.profit=float(film.receipts)-float(film.spent)
     film.director_income=float(film.get("director_income",0))+income
     log_message("Delayed rights payment for %s: ৳%.1f lakh to director."%[film.title,income])
func finish_film() -> void:
 var f: Dictionary = state.active
 f.stage=9
 var net: float = float(f.receipts)-float(f.spent)
 var income: float = float(f.receipts) if f.self_financed else Economy.director_profit(f.receipts,f.spent,f.backend,0)
 state.cash+=income
 f.director_income=income+float(f.fee)
 f.profit=net
 var rep_delta: float = clampf((f.quality-50)*.16+signf(net)*3,-10,12)
 state.industry=clampf(state.industry+rep_delta,0,100)
 state.critics=clampf(state.critics+(f.quality-45)*.22,0,100)
 state.audience=clampf(state.audience+(f.quality-40)*.16,0,100)
 state.stats.Direction=minf(100,state.stats.Direction+2)
 state.stats.Script=minf(100,state.stats.Script+1)
 if f.has("producer"):
  state.relationships[f.producer]=float(state.relationships.get(f.producer,0))+signf(net)*5
 unlock("First release")
 if net>0:
  unlock("In the black")
 if int(f.source)==4:
  unlock("Chapter two")
 log_message("Final theatrical statement: %s · producer profit ৳%.1f lakh · director payout ৳%.1f lakh."%[f.title,net,income])
func archive_film() -> void:
 if state.active.is_empty() or int(state.active.stage)!=9:
  return
 state.active.archived=true
 state.films.append(state.active.duplicate(true))
 state.active={}
 SaveManager.save_slot(0)
 EventBus.changed.emit()
func campaign(award_id: String) -> bool:
 var f: Dictionary = state.active
 var award: Dictionary = DataManager.entry("festivals_and_awards",award_id)
 if f.is_empty() or int(f.stage)!=9 or award.is_empty() or award_id in f.awards or state.cash<float(award.campaign_cost):
  return false
 state.cash-=float(award.campaign_cost)
 f.awards.append(award_id)
 var won: bool = f.quality+rng.randf_range(-config().award_random,config().award_random)+state.critics*.1>=float(award.threshold)
 if not f.has("award_results"): f.award_results={}
 f.award_results[award_id]=won
 if won:
  state.critics=clampf(state.critics+float(award.prestige),0,100)
  unlock("Award winner")
 log_message(("Won: " if won else "Campaign completed without a win: ")+award.name)
 EventBus.changed.emit()
 return won
func catalog_tick() -> void:
 for f in state.films:
  var royalty: float = Economy.rights_price(f.quality,f.hype,0,config())*.015*(1.0 if f.self_financed else float(f.backend))
  state.cash+=royalty
  f.catalog_income+=royalty
func rerelease(index: int) -> bool:
 if index<0 or index>=state.films.size():
  return false
 var f: Dictionary = state.films[index]
 if int(state.week)-int(f.last_catalog_week)<12 or state.cash<5:
  return false
 state.cash-=5
 var income: float = maxf(0,f.quality*.3*float(holiday_at(state.week).multiplier))
 state.cash+=income
 f.catalog_income+=income-5
 f.last_catalog_week=int(state.week)
 log_message("Restored cut of %s earns ৳%.1f lakh."%[f.title,income])
 EventBus.changed.emit()
 return true
func unlock(name_value: String) -> void:
 if not name_value in state.achievements:
  state.achievements.append(name_value)
  log_message("Achievement unlocked: "+name_value)
func career_action(action: String, stat: String = "Vision") -> bool:
 if state.is_empty() or state.retired or not state.pending_event.is_empty():
  return false
 match action:
  "train":
   if state.cash<config().training_cost:
    return false
   state.cash-=float(config().training_cost)
   state.stats[stat]=minf(100,float(state.stats[stat])+rng.randf_range(1,3))
   log_message("Masterclass completed: "+stat)
  "rest":
   state.stress=maxf(0,state.stress-float(config().recovery))
   log_message("A quiet week restores perspective.")
  "work":
   state.cash+=6+state.stats.Business*.05
   state.stress=clampf(state.stress+5,0,100)
   log_message("Commercial assignment delivered.")
  "loan":
   if state.debt+config().loan_amount>config().loan_limit:
    return false
   state.debt+=config().loan_amount
   state.cash+=config().loan_amount
   log_message("Bridge loan arranged. Interest accrues weekly.")
  "repay":
   var amount: float = minf(state.cash,state.debt)
   if amount<=0:
    return false
   state.cash-=amount
   state.debt-=amount
  "house":
   if state.house or state.cash<100:
    return false
   state.cash-=100
   state.house=true
   unlock("Studio founder")
  "mentor":
   state.industry=minf(100,state.industry+2)
   state.stats.Leadership=minf(100,state.stats.Leadership+1)
   log_message("A debut filmmaker benefits from your mentoring.")
  "retire":
   state.retired=true
   Clock.paused=true
   SaveManager.save_slot(0)
   EventBus.changed.emit()
   return true
 advance_week()
 return true
