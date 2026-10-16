extends Control
const Art = preload("res://scripts/ui/art_panel.gd")
const Chart = preload("res://scripts/ui/chart.gd")
const Verification = preload("res://scripts/sim/verify_career.gd")
const INK := Color("e5ede9")
const MUTED := Color("92a8b0")
const MINT := Color("65dfbf")
const GOLD := Color("e8c58b")
var page: String = "Main menu"
var body: VBoxContainer
var workspace: VBoxContainer
var fields: Dictionary = {}
var selected_traits: Array = []
var redraw_pending: bool = false
var return_page: String = "Dashboard"
func _ready() -> void:
 build_theme()
 EventBus.changed.connect(schedule_render)
 render()
 if "--verify-career" in OS.get_cmdline_user_args():
  call_deferred("verify_export")
 if "--smoke-ui" in OS.get_cmdline_user_args():
  call_deferred("smoke_ui")
 if "--capture-ui" in OS.get_cmdline_user_args():
  call_deferred("capture_ui")
func build_theme() -> void:
 var theme_data := Theme.new()
 var base: Font = ThemeDB.fallback_font.duplicate()
 base.fallbacks=[load("res://assets/fonts/NotoSansBengali.ttf")]
 theme_data.default_font=base
 theme_data.default_font_size=int(GameState.settings.font_size)
 theme_data.set_color("font_color","Label",INK)
 theme_data.set_color("font_color","Button",INK)
 theme_data.set_color("font_hover_color","Button",MINT)
 for type in ["Button","OptionButton","LineEdit","SpinBox"]:
  theme_data.set_stylebox("normal",type,box(Color("172d38"),8,12))
  theme_data.set_stylebox("hover",type,box(Color("24454c"),8,12))
  theme_data.set_stylebox("pressed",type,box(Color("2c655d"),8,12))
  var focus_box := box(Color("1a3942"),8,12)
  focus_box.border_color=MINT
  focus_box.set_border_width_all(2)
  theme_data.set_stylebox("focus",type,focus_box)
 theme_data.set_stylebox("normal","TextEdit",box(Color("10232e"),8,12))
 theme_data.set_color("font_color","TextEdit",INK)
 theme_data.set_color("font_color","LineEdit",INK)
 theme_data.set_stylebox("panel","PopupMenu",box(Color("162e38"),8,8))
 theme_data.set_color("font_color","PopupMenu",INK)
 theme_data.set_constant("separation","VBoxContainer",12)
 theme_data.set_constant("separation","HBoxContainer",14)
 theme_data.set_stylebox("background","ProgressBar",box(Color("223943"),4,0))
 theme_data.set_stylebox("fill","ProgressBar",box(MINT,4,0))
 theme=theme_data
 get_tree().root.content_scale_factor=float(GameState.settings.ui_scale)
func box(color: Color, radius: int = 12, margin: int = 20) -> StyleBoxFlat:
 var style := StyleBoxFlat.new()
 style.bg_color=color
 style.set_corner_radius_all(radius)
 style.content_margin_left=margin
 style.content_margin_right=margin
 style.content_margin_top=margin
 style.content_margin_bottom=margin
 return style
func schedule_render() -> void:
 if not redraw_pending:
  redraw_pending=true
  call_deferred("render")
func go(destination: String) -> void:
 Clock.paused=true
 page=destination
 render()
func render() -> void:
 redraw_pending=false
 fields={}
 for child in get_children():
  remove_child(child)
  child.queue_free()
 var bg := ColorRect.new()
 bg.color=Color("0b171f")
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(bg)
 var margin := MarginContainer.new()
 margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 for side in ["left","right","top","bottom"]:
  margin.add_theme_constant_override("margin_"+side,28)
 add_child(margin)
 var root := VBoxContainer.new()
 margin.add_child(root)
 if page=="Main menu":
  menu(root)
  return
 var header := hbox(root)
 label(header,"THE DIRECTOR",22,GOLD)
 label(header,"/ DHALLYWOOD",15,MUTED)
 spacer(header)
 if not GameState.state.is_empty():
  label(header,GameState.date_text(),16,MUTED)
 button(header,"Menu",func(): go("Main menu"))
 if page=="New career":
  body=scroll(root)
  character_creation()
  return
 var split := hbox(root)
 split.size_flags_vertical=Control.SIZE_EXPAND_FILL
 var nav_scroll := ScrollContainer.new()
 nav_scroll.custom_minimum_size.x=205
 nav_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 split.add_child(nav_scroll)
 var nav := VBoxContainer.new()
 nav.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 nav.size_flags_vertical=Control.SIZE_EXPAND_FILL
 nav_scroll.add_child(nav)
 for destination in ["Dashboard","Film studio","New screenplay","Release calendar","Filmography","Relationships","Industry news","Career","Achievements","Save manager","Settings","Credits"]:
  var b := button(nav,destination,func(): go(destination))
  b.alignment=HORIZONTAL_ALIGNMENT_LEFT
  if destination==page:
   b.add_theme_color_override("font_color",MINT)
 spacer(nav,true)
 label(nav,"DHAKA • 2026 ONWARD",11,MUTED)
 label(nav,"All money in lakh BDT",11,MUTED)
 workspace=VBoxContainer.new()
 workspace.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 split.add_child(workspace)
 var heading := hbox(workspace)
 label(heading,page,28,INK)
 spacer(heading)
 if not GameState.state.is_empty() and not GameState.state.retired:
  button(heading,"Ⅱ" if not Clock.paused else "▶",func(): Clock.paused=not Clock.paused; schedule_render(),"Pause / auto-advance. Space toggles time.")
  var speed := option(heading,["1×","2×","4×"],[1,2,4].find(Clock.speed))
  speed.item_selected.connect(func(i: int): Clock.speed=[1,2,4][i])
  button(heading,Localization.text("next_week")+"  →",func(): GameState.advance_week(),"Advance one week. Events require a decision first.")
 body=scroll(workspace)
 match page:
  "Dashboard": dashboard()
  "New screenplay": screenplay()
  "Film studio": studio()
  "Release calendar": calendar()
  "Filmography": filmography()
  "Relationships": relationships()
  "Industry news": news()
  "Career": career()
  "Achievements": achievements()
  "Save manager": saves()
  "Settings": settings_screen()
  "Credits": credits()
 if not GameState.state.is_empty() and not GameState.state.pending_event.is_empty():
  show_event()
 if not GameState.state.is_empty() and GameState.state.retired:
  label(body,"CAREER COMPLETE · Your films are your legacy.",26,GOLD)
func label(parent: Node, text: String, size_value: int = 16, color: Color = INK) -> Label:
 var node := Label.new()
 node.text=text
 node.add_theme_font_size_override("font_size",size_value+int(GameState.settings.font_size)-16)
 node.add_theme_color_override("font_color",color)
 node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 node.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 parent.add_child(node)
 return node
func button(parent: Node, text: String, action: Callable, hint: String = "") -> Button:
 var node := Button.new()
 node.text=text
 node.custom_minimum_size.y=42
 node.tooltip_text=hint if not hint.is_empty() else text
 node.pressed.connect(func(): AudioManager.click(); action.call())
 parent.add_child(node)
 return node
func hbox(parent: Node) -> HBoxContainer:
 var node := HBoxContainer.new()
 parent.add_child(node)
 return node
func spacer(parent: Node, vertical: bool = false) -> void:
 var node := Control.new()
 if vertical:
  node.size_flags_vertical=Control.SIZE_EXPAND_FILL
 else:
  node.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 parent.add_child(node)
func scroll(parent: Node) -> VBoxContainer:
 var area := ScrollContainer.new()
 area.size_flags_vertical=Control.SIZE_EXPAND_FILL
 area.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 area.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 parent.add_child(area)
 var contents := VBoxContainer.new()
 contents.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 contents.add_theme_constant_override("separation",18)
 area.add_child(contents)
 return contents
func card(parent: Node, title: String, subtitle: String = "") -> VBoxContainer:
 var panel := PanelContainer.new()
 panel.add_theme_stylebox_override("panel",box(Color("132630")))
 panel.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 parent.add_child(panel)
 var content := VBoxContainer.new()
 panel.add_child(content)
 if not title.is_empty():
  label(content,title,19,INK)
 if not subtitle.is_empty():
  label(content,subtitle,14,MUTED)
 return content
func option(parent: Node, items: Array, selected: int = 0) -> OptionButton:
 var node := OptionButton.new()
 node.custom_minimum_size.y=42
 node.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 for item in items:
  node.add_item(str(item))
 node.select(clampi(selected,0,maxi(0,items.size()-1)))
 parent.add_child(node)
 return node
func names(table: String) -> Array:
 return DataManager.rows(table).map(func(row: Dictionary): return DataManager.display_name(row))
func line(parent: Node, title: String, value: String = "", multiline: bool = false) -> Control:
 label(parent,title,13,MUTED)
 var node: Control
 if multiline:
  var edit := TextEdit.new()
  edit.custom_minimum_size.y=100
  edit.text=value
  edit.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
  node=edit
 else:
  var edit := LineEdit.new()
  edit.text=value
  edit.custom_minimum_size.y=42
  node=edit
 parent.add_child(node)
 return node
func spin(parent: Node, title: String, value: float, low: float, high: float, step: float = 1) -> SpinBox:
 label(parent,title,13,MUTED)
 var node := SpinBox.new()
 node.min_value=low
 node.max_value=high
 node.step=step
 node.value=value
 node.custom_minimum_size.y=42
 parent.add_child(node)
 return node
func meter(parent: Node, title: String, value: float, total: float = 100) -> void:
 label(parent,"%s  ·  %.0f / %.0f"%[title,value,total],13,MUTED)
 var bar := ProgressBar.new()
 bar.custom_minimum_size.y=7
 bar.max_value=maxf(1,total)
 bar.show_percentage=false
 parent.add_child(bar)
 var tween := create_tween()
 tween.tween_property(bar,"value",value,.4).set_trans(Tween.TRANS_CUBIC)
func menu(root: VBoxContainer) -> void:
 var row := hbox(root)
 row.size_flags_vertical=Control.SIZE_EXPAND_FILL
 var left_scroll := ScrollContainer.new()
 left_scroll.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 left_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 row.add_child(left_scroll)
 var left := VBoxContainer.new()
 left.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 left.size_flags_vertical=Control.SIZE_EXPAND_FILL
 left_scroll.add_child(left)
 spacer(left,true)
 label(left,"A FILMMAKER’S LIFE",14,MINT)
 label(left,"THE\nDIRECTOR",70,INK)
 label(left,"D H A L L Y W O O D",23,GOLD)
 label(left,Localization.text("welcome"),20,MUTED)
 label(left,"Write the story. Build the team.\nMake opening night mean something.",17,MUTED)
 var actions := VBoxContainer.new()
 actions.custom_minimum_size.x=310
 left.add_child(actions)
 button(actions,Localization.text("new_career"),func(): selected_traits=[]; go("New career"))
 if not GameState.state.is_empty():
  button(actions,"Resume career",func(): go("Dashboard"))
 if not SaveManager.read_slot(0).is_empty():
  button(actions,Localization.text("continue_game"),func(): if SaveManager.load_slot(0): go("Dashboard"))
 button(actions,Localization.text("settings"),func(): go("Settings"))
 button(actions,"Load career",func(): go("Save manager"))
 button(actions,"Credits",func(): go("Credits"))
 button(actions,"Quit",func(): get_tree().quit())
 spacer(left,true)
 label(left,"DESKTOP CAREER SIMULATION  /  v0.1",11,MUTED)
 var art := Art.new()
 art.custom_minimum_size=Vector2(460,400)
 art.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 art.size_flags_vertical=Control.SIZE_EXPAND_FILL
 art.title="Dhaka, after the rain"
 row.add_child(art)
func character_creation() -> void:
 label(body,"Every director has an origin story.",32,INK)
 label(body,"Create a filmmaker • choose two traits • spend up to 405 stat points",16,MUTED)
 var row := hbox(body)
 var profile := card(row,"Your identity")
 fields.name=line(profile,"Name","Arian Rahman")
 fields.age=spin(profile,"Age",26,18,60)
 label(profile,"Gender / home district",13,MUTED)
 fields.gender=option(profile,DataManager.config("economy").genders)
 fields.district=option(profile,DataManager.config("economy").districts)
 label(profile,"Background",13,MUTED)
 fields.background=option(profile,names("backgrounds"))
 var origin := label(profile,"",14,GOLD)
 var update_origin := func(i: int):
  var bg: Dictionary = DataManager.rows("backgrounds")[i]
  origin.text="৳%d lakh · %d contacts · +%d %s\n%s"%[bg.cash,bg.contacts,bg.bonus,bg.bonus_stat,bg.problem]
 update_origin.call(0)
 fields.background.item_selected.connect(update_origin)
 fields.avatar=spin(profile,"Avatar palette",0,0,9)
 fields.seed=spin(profile,"World seed",342,1,2147483646)
 var skills := card(row,"The craft","405 points before background and trait bonuses.")
 fields.stats={}
 var remaining := label(skills,"45 points remaining",14,MINT)
 for stat in DataManager.config("economy").stats:
  var control := spin(skills,stat,40,0,100)
  fields.stats[stat]=control
  control.value_changed.connect(func(_v: float):
   var total: int = 0
   for field in fields.stats.values(): total+=int(field.value)
   remaining.text="%d points remaining"%(405-total)
   remaining.modulate=Color.WHITE if total<=405 else Color("ed9566")
  )
 var traits := card(body,"Two defining traits")
 var grid := GridContainer.new()
 grid.columns=5
 traits.add_child(grid)
 for trait_data in DataManager.rows("traits"):
  var check := CheckBox.new()
  check.text=trait_data.name
  check.tooltip_text="+%d %s"%[trait_data.bonus,trait_data.stat]
  check.button_pressed=trait_data.id in selected_traits
  grid.add_child(check)
  check.toggled.connect(func(enabled: bool):
   if enabled and selected_traits.size()>=2:
    check.set_pressed_no_signal(false)
   elif enabled:
    selected_traits.append(trait_data.id)
   else:
    selected_traits.erase(trait_data.id)
  )
 var error := label(body,"",14,Color("ed9566"))
 button(body,"Begin your career  →",func():
  var total: int = 0
  var stats: Dictionary = {}
  for stat in fields.stats:
   stats[stat]=int(fields.stats[stat].value)
   total+=stats[stat]
  if total>405 or selected_traits.size()!=2 or fields.name.text.strip_edges().is_empty():
   error.text="Enter a name, choose exactly two traits and stay within 405 points."
   return
  GameState.new_career({"name":fields.name.text.strip_edges(),"age":int(fields.age.value),"gender":fields.gender.get_item_text(fields.gender.selected),"district":fields.district.get_item_text(fields.district.selected),"background":fields.background.selected,"traits":selected_traits.duplicate(),"avatar":int(fields.avatar.value),"stats":stats},int(fields.seed.value))
  SaveManager.save_slot(0)
  go("Dashboard")
 )
func dashboard() -> void:
 if not require_career(): return
 var s: Dictionary = GameState.state
 var metrics := hbox(body)
 metric(metrics,"CASH","৳%.1f L"%s.cash,MINT)
 metric(metrics,"INDUSTRY","%.0f / 100"%s.industry,GOLD)
 metric(metrics,"CRITICS","%.0f / 100"%s.critics,Color("b59de0"))
 metric(metrics,"AUDIENCE","%.0f / 100"%s.audience,Color("80b7e8"))
 var row := hbox(body)
 var focus := card(row,"Your next story",GameState.holiday_at(s.week).name+" · "+GameState.date_text())
 if s.active.is_empty():
  label(focus,"The slate is yours.",30,INK)
  label(focus,"A new screenplay is the first step toward your next opening night.",16,MUTED)
  button(focus,"Develop a film  →",func(): go("New screenplay"))
 else:
  label(focus,s.active.title,30,INK)
  label(focus,DataManager.config("content").stage_labels[int(s.active.stage)],17,MINT)
  meter(focus,"Stage progress",s.active.progress,maxf(1,s.active.stage_total))
  label(focus,DataManager.config("content").tips[int(s.active.stage)],15,MUTED)
  button(focus,"Open film studio  →",func(): go("Film studio"))
 var life := card(row,s.director.name,"%s · Age %d"%[s.director.district,s.director.age])
 var avatar := Art.new()
 avatar.mode="portrait"
 avatar.custom_minimum_size=Vector2(80,80)
 avatar.tint=Color(DataManager.rows("genres")[int(s.director.get("avatar",0))%8].color)
 life.add_child(avatar)
 meter(life,"Burnout",s.stress)
 label(life,"Debt: ৳%.1f lakh\nCompleted films: %d"%[s.debt,s.films.size()],16,MUTED)
 button(life,"Take a recovery week",func(): GameState.career_action("rest"))
 var inbox := card(body,"The desk","Offers, production reports and decisions")
 for item in s.inbox.slice(0,6):
  label(inbox,"W%02d   %s"%[int(item.week),item.text],14,MUTED)
func metric(parent: Node, title: String, value: String, color: Color) -> void:
 var content := card(parent,"")
 label(content,title,11,MUTED)
 label(content,value,25,color)
func require_career() -> bool:
 if GameState.state.is_empty():
  label(body,"Start or load a career to use this screen.",20,MUTED)
  button(body,"New career",func(): go("New career"))
  return false
 return true
func screenplay() -> void:
 if not require_career(): return
 if not GameState.state.active.is_empty():
  label(body,"Finish and archive your current film before starting another.",18,MUTED)
  button(body,"Open current film",func(): go("Film studio"))
  return
 var row := hbox(body)
 var paper := card(row,"A blank page. A thousand possibilities.")
 fields.title=line(paper,"Film title")
 fields.logline=line(paper,"Logline")
 fields.synopsis=line(paper,"Synopsis","",true)
 fields.setting=line(paper,"Setting","Dhaka")
 var details := card(row,"Creative brief")
 fields.genre=option(details,names("genres"))
 fields.theme=option(details,DataManager.config("content").themes)
 fields.tone=option(details,DataManager.config("content").tones)
 fields.era=option(details,DataManager.config("content").eras)
 fields.rating=option(details,DataManager.config("content").ratings)
 fields.source=option(details,DataManager.config("content").sources)
 var tier_names: Array = DataManager.config("economy").tiers.map(func(t: Dictionary): return "%s · ৳%d L"%[t.name,t.budget])
 fields.tier=option(details,tier_names)
 var error := label(body,"",14,Color("ed9566"))
 button(body,"Put it into development  →",func():
  var idea: Dictionary = {"title":fields.title.text,"logline":fields.logline.text,"synopsis":fields.synopsis.text,"setting":fields.setting.text,"genre":fields.genre.selected,"theme":fields.theme.get_item_text(fields.theme.selected),"tone":fields.tone.get_item_text(fields.tone.selected),"era":fields.era.get_item_text(fields.era.selected),"rating":fields.rating.get_item_text(fields.rating.selected),"source":fields.source.selected,"tier":fields.tier.selected}
  if GameState.create_film(idea): go("Film studio")
  else: error.text="Enter a title. Sequels and reboots require a completed film in your catalog."
 )
func studio() -> void:
 if not require_career(): return
 var f: Dictionary = GameState.state.active
 if f.is_empty():
  label(body,"No film in production.",22,MUTED)
  button(body,"Start a screenplay",func(): go("New screenplay"))
  return
 var summary := hbox(body)
 var poster := Art.new()
 poster.custom_minimum_size=Vector2(200,240)
 poster.title=f.title
 poster.tint=Color(DataManager.rows("genres")[int(f.genre)].color)
 summary.add_child(poster)
 var details := card(summary,f.title,f.get("logline",""))
 label(details,DataManager.config("content").stage_labels[int(f.stage)].to_upper(),14,MINT)
 meter(details,"Schedule",minf(f.progress,f.stage_total),maxf(1,f.stage_total))
 var metrics := hbox(details)
 metric(metrics,"BUDGET","৳%.0f L"%f.budget,GOLD)
 metric(metrics,"SPENT","৳%.1f L"%f.spent,MINT)
 metric(metrics,"QUALITY","%.0f"%f.quality,INK)
 metric(metrics,"HYPE","%.0f"%f.hype,INK)
 label(body,DataManager.config("content").tips[int(f.stage)],16,GOLD)
 match int(f.stage):
  0: development(f)
  1: financing(f)
  2: packaging(f)
  3: preproduction(f)
  4: production(f)
  5: post(f)
  6: marketing(f)
  7: distribution(f)
  8: boxoffice(f)
  9: after_release(f)
func development(f: Dictionary) -> void:
 var panel := card(body,"The writer’s room","Develop the draft over three weeks. Script skill, vision and writer support matter.")
 meter(panel,"Script quality",f.script)
 label(panel,f.synopsis if not str(f.synopsis).is_empty() else "Your synopsis will appear here.",15,MUTED)
 button(panel,"Hire a script consultant · ৳4 L",func():
  if GameState.state.cash>=4:
   GameState.charge_film(f,4)
   f.writer=minf(100,f.writer+20)
   GameState.log_message("A consultant strengthens the draft.")
   schedule_render()
 )
 button(panel,"Rewrite draft · one week",func():
  f.progress=maxi(0,int(f.progress)-1)
  f.writer=minf(100,f.writer+5)
  GameState.advance_week()
 )
func financing(f: Dictionary) -> void:
 var panel := card(body,"The pitch room","Negotiate your share and final cut. Ambitious terms reduce acceptance.")
 var backend := spin(panel,"Backend %",10,0,50)
 var control := spin(panel,"Creative control %",60,0,100)
 for p in DataManager.rows("producers"):
  var row := hbox(panel)
  label(row,"%s · %s · up to ৳%d L · %s"%[DataManager.display_name(p),p.personality,p.budget_range[1],p.red_flag],14,MUTED)
  button(row,"Pitch",func(): GameState.finance(p.id,backend.value/100,int(control.value)))
 var own := button(panel,"Self-finance · remaining ৳%.1f L"%(f.budget-f.spent),func(): GameState.self_finance())
 own.disabled=GameState.state.cash<f.budget-f.spent
func packaging(f: Dictionary) -> void:
 var panel := card(body,"The ensemble","Hire at least one performer and one crew member. Fees are charged to the film.")
 label(panel,"Cast: %d / 3   •   Crew: %d / 12   •   Star power: %.0f"%[f.cast.size(),f.crew.size(),f.star],16,MINT)
 var tabs := TabContainer.new()
 tabs.custom_minimum_size.y=380
 panel.add_child(tabs)
 for table in ["actors","actresses","new_talent","crew"]:
  var area := ScrollContainer.new()
  area.name=table.capitalize()
  tabs.add_child(area)
  var list := VBoxContainer.new()
  list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  area.add_child(list)
  for p in DataManager.rows(table):
   var row := hbox(list)
   label(row,"%s · %s · Tier %d · ৳%.0f L · %.0f%% available"%[DataManager.display_name(p),p.profession,p.tier,p.fee_range[0],p.availability*100],14,MUTED)
   var hired: bool = p.id in f.cast or p.id in f.crew
   var hire_button := button(row,"Hired" if hired else "Hire",func(): GameState.hire(table,p.id))
   hire_button.disabled=hired
 button(panel,"Lock package  →",func(): GameState.complete_packaging()).disabled=f.cast.is_empty() or f.crew.is_empty()
func preproduction(f: Dictionary) -> void:
 var panel := card(body,"Plan before the first call","Permits, scouting, rehearsals and safety reduce production risk.")
 var plan := option(panel,["Lean prep","Balanced prep","Safety-first prep"],int(f.plan))
 plan.item_selected.connect(func(i: int): f.plan=i)
 var locations := option(panel,names("locations"),int(f.get("location",0)))
 locations.item_selected.connect(func(i: int): f.location=i)
 label(panel,"Planned shoot: %d days · base ৳%.1f L / day"%[DataManager.config("economy").tiers[int(f.tier)].days,DataManager.config("economy").tiers[int(f.tier)].daily_cost],17,GOLD)
 var budget := spin(panel,"Revised production ceiling (lakh BDT)",f.budget,30,2000,10)
 budget.value_changed.connect(func(v: float): f.budget=v)
func production(f: Dictionary) -> void:
 var panel := card(body,"On location","Every week consumes crew days. Protect quality, money and your stamina.")
 var strategy := option(panel,["Balanced shoot","Cut coverage · lower cost, lower quality","Reshoot / perfection · higher cost, higher quality"],int(f.production_strategy))
 strategy.item_selected.connect(func(i: int): f.production_strategy=i)
 meter(panel,"Production risk",f.risk*100)
 meter(panel,"Director burnout",GameState.state.stress)
func post(f: Dictionary) -> void:
 var panel := card(body,"Finding the film in the edit","Picture, colour, VFX, sound and music mix. Restricted certificates incur cuts.")
 var approach := option(panel,["Assembly cut","Fine edit & colour","Full sound / VFX polish"],int(f.post_plan))
 approach.item_selected.connect(func(i: int): f.post_plan=i)
 label(panel,"Rating target: "+f.rating,18,GOLD)
 var rating := option(panel,DataManager.config("content").ratings,DataManager.config("content").ratings.find(f.rating))
 rating.item_selected.connect(func(i: int): f.rating=DataManager.config("content").ratings[i])
func marketing(f: Dictionary) -> void:
 var panel := card(body,"Let the audience find you","Poster → teaser → trailer → songs → press. Spend helps hype; the film must deliver.")
 var spend := spin(panel,"Campaign spend per week (lakh BDT)",f.marketing_spend,0,60,2)
 spend.value_changed.connect(func(v: float): f.marketing_spend=v)
 meter(panel,"Audience anticipation",f.hype)
 label(panel,"Campaign material is generated from your title and genre palette.",14,MUTED)
func distribution(f: Dictionary) -> void:
 var panel := card(body,"Opening night is a strategic choice","Avoid clashes or chase an Eid window. Rights deals are paid after their windows.")
 var screens := spin(panel,"Booked screens",f.screens,5,180,5)
 screens.value_changed.connect(func(v: float): f.screens=int(v))
 var release := spin(panel,"Release week (absolute career week)",maxi(GameState.state.week,f.release_week),GameState.state.week,GameState.state.week+104)
 f.release_week=int(release.value)
 release.value_changed.connect(func(v: float): f.release_week=int(v))
 label(panel,"Chosen window: %s · competition pressure %.0f%%"%[GameState.holiday_at(f.release_week).name,GameState.competition_at(f.release_week)*100],16,GOLD)
 button(panel,"Open in cinemas  →",func(): GameState.begin_release()).disabled=int(GameState.state.week)<int(f.release_week)
 rights_table(f)
func rights_table(f: Dictionary) -> void:
 var panel := card(body,"Rights & distribution","Exclusive per category / territory. Theatrical receipts use 20% single-screen and 31–38% multiplex shares.")
 for table in ["overseas_markets","ott_platforms","tv_channels","music_labels"]:
  var exclusive: bool = false
  if table!="overseas_markets":
   for key in f.rights:
    if f.rights[key].category==table: exclusive=true
  for buyer in DataManager.rows(table):
   var row := hbox(panel)
   label(row,"%s · %s · window +%d weeks"%[DataManager.display_name(buyer),table.replace("_"," "),int(buyer.get("window",0))],14,MUTED)
   var sold: bool = f.rights.has(table+buyer.id)
   var b := button(row,"Signed" if sold else "Negotiate license",func(): GameState.sell_rights(table,buyer.id))
   b.disabled=sold or exclusive
func boxoffice(f: Dictionary) -> void:
 var panel := card(body,"The box office","Gross ticket sales are not producer income. Watch retention and the break-even line.")
 var row := hbox(panel)
 metric(row,"GROSS","৳%.1f L"%f.gross,MINT)
 metric(row,"RECEIPTS","৳%.1f L"%f.receipts,GOLD)
 metric(row,"BREAK-EVEN GAP","৳%.1f L"%maxf(0,f.spent-f.receipts),INK)
 var chart := Chart.new()
 chart.history=f.history
 panel.add_child(chart)
 label(panel,f.get("review",""),18,GOLD)
 label(panel,"Reviews: %.0f / 100   •   Opening occupancy: %.0f%%   •   Word of mouth follows quality"%[f.quality,f.opening*100],16,MUTED)
 for point in f.history:
  label(panel,"W%d    gross ৳%.1f L    producer ৳%.1f L"%[point.week,point.gross,point.receipts],14,MUTED)
 rights_table(f)
func after_release(f: Dictionary) -> void:
 var panel := card(body,"The final statement", "Opening night becomes a filmography.")
 var row := hbox(panel)
 metric(row,"PRODUCER PROFIT","৳%.1f L"%f.profit,MINT if f.profit>=0 else Color("ed9566"))
 metric(row,"DIRECTOR INCOME","৳%.1f L"%f.director_income,GOLD)
 label(panel,"Quality %.0f · Gross ৳%.1f L · Cost ৳%.1f L"%[f.quality,f.gross,f.spent],18,INK)
 var chart := Chart.new()
 chart.history=f.history
 panel.add_child(chart)
 var awards := card(body,"Awards season","A campaign buys consideration; quality and jury variation determine the outcome.")
 for award in DataManager.rows("festivals_and_awards"):
  var campaign_row := hbox(awards)
  label(campaign_row,award.name,16,MUTED)
  button(campaign_row,"Considered" if award.id in f.awards else "Campaign · ৳%d L"%award.campaign_cost,func(): GameState.campaign(award.id)).disabled=award.id in f.awards
 button(body,"Archive film & develop your next story  →",func(): GameState.archive_film(); go("Filmography"))
func calendar() -> void:
 if not require_career(): return
 var panel := card(body,"The release calendar","Holiday weeks are approximate planning windows; actual lunar dates change annually.")
 for holiday in DataManager.rows("holidays"):
  label(panel,"W%02d  •  %s  •  %.2f× opening demand"%[holiday.week,holiday.name,holiday.multiplier],16,GOLD)
 var slate := card(body,"Rival slate","AI competitors announce a new seasonal slate every 13 weeks.")
 var rivals: Array = GameState.state.rivals.duplicate(true)
 rivals.sort_custom(func(a: Dictionary,b: Dictionary): return int(a.week)<int(b.week))
 for rival in rivals:
  if rival.week>=GameState.state.week-8:
   label(slate,"Week %d   /   %s   /   competitive strength %.0f%%"%[rival.week,rival.title,rival.strength*100],15,MUTED)
func filmography() -> void:
 if not require_career(): return
 if GameState.state.films.is_empty(): label(body,"Your credits will live here. Finish and archive your first film.",18,MUTED)
 for i in range(GameState.state.films.size()):
  var f: Dictionary = GameState.state.films[i]
  var panel := card(body,f.title,"%s • %s"%[DataManager.rows("genres")[int(f.genre)].name,f.get("theme","")])
  label(panel,"Quality %.0f  •  Gross ৳%.1f L  •  Producer profit ৳%.1f L  •  Catalog income ৳%.1f L"%[f.quality,f.gross,f.profit,f.catalog_income],16,MUTED)
  for award_id in f.get("award_results",{}):
   if f.award_results[award_id]: label(panel,"★ "+DataManager.entry("festivals_and_awards",award_id).name,15,GOLD)
  var row := hbox(panel)
  button(row,"Develop sequel",func():
   if GameState.state.active.is_empty():
    var idea: Dictionary = {"title":f.title+" II","logline":f.logline,"synopsis":f.synopsis,"setting":f.setting,"genre":f.genre,"theme":f.theme,"tone":f.tone,"era":f.era,"rating":f.rating,"source":4,"tier":f.tier}
    GameState.create_film(idea)
    go("Film studio")
  ).disabled=not GameState.state.active.is_empty()
  button(row,"Restore / re-release · ৳5 L",func(): GameState.rerelease(i))
func relationships() -> void:
 if not require_career(): return
 label(body,"Working relationships shape future pitch acceptance and persist across saves.",16,MUTED)
 for table in ["producers","actors","actresses","crew"]:
  for person in DataManager.rows(table):
   if GameState.state.relationships.has(person.id):
    var panel := card(body,DataManager.display_name(person),person.profession)
    label(panel,"Relationship: %+.0f"%GameState.state.relationships[person.id],16,MINT)
func news() -> void:
 if not require_career(): return
 for item in GameState.state.inbox:
  var panel := card(body,"Week %d"%item.week)
  label(panel,item.text,16,MUTED)
func career() -> void:
 if not require_career(): return
 var s: Dictionary = GameState.state
 var panel := card(body,s.director.name,"Life beyond the set")
 meter(panel,"Burnout",s.stress)
 label(panel,"Cash ৳%.1f L • Debt ৳%.1f L • %s"%[s.cash,s.debt,"Own production house" if s.house else "Independent director"],17,GOLD)
 for stat in s.stats:
  var row := hbox(panel)
  label(row,"%s  %.0f / 100"%[stat,s.stats[stat]],15,MUTED)
  button(row,"Masterclass · ৳3 L",func(): GameState.career_action("train",stat))
 var actions := card(body,"Career choices","Each choice advances one week. Financial recovery remains available after a flop.")
 for item in [["rest","Take a recovery week"],["work","Direct an advertisement · paid work"],["loan","Bridge loan · ৳80 L"],["repay","Repay available debt"],["house","Found a production house · ৳100 L"],["mentor","Mentor a debut filmmaker"]]:
  button(actions,item[1],func(): GameState.career_action(item[0]))
 button(actions,"Retire and view legacy",func():
  var dialog := ConfirmationDialog.new()
  dialog.dialog_text="Retire this director? Save a manual slot first if you want to return."
  add_child(dialog)
  dialog.confirmed.connect(func(): GameState.career_action("retire"))
  dialog.popup_centered()
 )
func achievements() -> void:
 if not require_career(): return
 for achievement in ["First release","In the black","Chapter two","Award winner","Studio founder"]:
  var unlocked: bool = achievement in GameState.state.achievements
  var panel := card(body,("✓  " if unlocked else "○  ")+achievement)
  label(panel,"Unlocked" if unlocked else "Keep building your career",15,MINT if unlocked else MUTED)
func saves() -> void:
 label(body,"Five manual slots and a separate weekly autosave. Loading pauses the calendar.",16,MUTED)
 for slot in range(6):
  var panel := card(body,"Autosave" if slot==0 else "Slot %d"%slot,SaveManager.label_for(slot))
  var row := hbox(panel)
  if slot>0:
   button(row,"Save here",func():
    var dialog := ConfirmationDialog.new()
    dialog.dialog_text="Save current career to slot %d? Existing contents will be replaced."%slot
    add_child(dialog)
    dialog.confirmed.connect(func():
     var result: Error = SaveManager.save_slot(slot)
     if result==OK: schedule_render()
    )
    dialog.popup_centered()
   ).disabled=GameState.state.is_empty()
  button(row,"Load",func():
   if SaveManager.load_slot(slot): go("Dashboard")
  ).disabled=SaveManager.read_slot(slot).is_empty()
func settings_screen() -> void:
 var panel := card(body,"Make yourself comfortable")
 for setting in [["music","Calm music"],["sound","UI sounds"],["fictionalize","Fictionalize names"]]:
  var check := CheckBox.new()
  check.text=setting[1]
  check.button_pressed=GameState.settings.get(setting[0],true)
  panel.add_child(check)
  check.toggled.connect(func(enabled: bool):
   GameState.settings[setting[0]]=enabled
   AudioManager.update_volume()
   SaveManager.save_settings()
  )
 var scale_control := spin(panel,"UI scale (apply below)",GameState.settings.ui_scale,.8,1.4,.1)
 var font_control := spin(panel,"Font size (apply below)",GameState.settings.font_size,14,24,1)
 label(panel,"Language: English UI, Bengali navigation preview",14,MUTED)
 var language_control := option(panel,["English","বাংলা · navigation preview"],0 if GameState.settings.language=="en" else 1)
 button(panel,"Apply display settings",func():
  GameState.settings.ui_scale=scale_control.value
  GameState.settings.font_size=font_control.value
  GameState.settings.language="en" if language_control.selected==0 else "bn"
  Localization.language=GameState.settings.language
  SaveManager.save_settings()
  build_theme()
  render()
 )
 label(panel,"All people and benchmark films in this edition are fictional. Platform and festival names identify public services; monetary figures are estimates, editable under data/. Noto Sans Bengali is bundled. Full Bengali translation is not yet included.",15,MUTED)
func credits() -> void:
 var panel := card(body,"THE DIRECTOR: Dhallywood","A desktop filmmaking career simulation")
 for credit in DataManager.config("content").credits:
  label(panel,credit,17,MUTED)
func show_event() -> void:
 Clock.paused=true
 var event: Dictionary = GameState.state.pending_event
 var overlay := ColorRect.new()
 overlay.color=Color(0,0,0,.75)
 overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(overlay)
 var center := CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 overlay.add_child(center)
 var panel := card(center,"A decision on your desk",event.name)
 panel.custom_minimum_size.x=650
 label(panel,event.description,20,INK)
 for i in range(event.choices.size()):
  var choice: Dictionary = event.choices[i]
  button(panel,"%s   /   ৳%+.0f L · quality %+.0f · hype %+.0f"%[choice.label,choice.cash,choice.quality,choice.hype],func(): GameState.choose_event(i))
func _unhandled_key_input(event: InputEvent) -> void:
 if not event is InputEventKey or not event.pressed or event.echo:
  return
 if get_viewport().gui_get_focus_owner() is LineEdit or get_viewport().gui_get_focus_owner() is TextEdit:
  return
 if event.keycode==KEY_SPACE and not GameState.state.is_empty():
  Clock.paused=not Clock.paused
  schedule_render()
 elif event.keycode==KEY_N and not GameState.state.is_empty():
  GameState.advance_week()
 elif event.keycode==KEY_ESCAPE:
  go("Main menu" if page!="Main menu" else "Dashboard")
func smoke_ui() -> void:
 GameState.new_career({"name":"UI Test","age":26,"district":"Dhaka","background":0,"traits":["trait_0","trait_1"]},342)
 for screen in ["Main menu","New career","Dashboard","New screenplay","Release calendar","Filmography","Relationships","Industry news","Career","Achievements","Save manager","Settings","Credits"]:
  go(screen)
  await get_tree().process_frame
 GameState.create_film({"title":"UI Test","logline":"A test","synopsis":"Test","setting":"Dhaka","genre":0,"tier":0,"source":0,"rating":"U","theme":"Belonging","tone":"Hopeful","era":"Present day"})
 for stage in range(10):
  var f: Dictionary = GameState.state.active
  f.stage=stage
  f.quality=65
  f.director_income=15
  f.profit=20
  f.opening=.5
  go("Film studio")
  await get_tree().process_frame
 print("UI_SMOKE_OK: 13 screens and all 10 film stages rendered")
 get_tree().quit()

func capture_ui() -> void:
 DirAccess.make_dir_recursive_absolute("res://builds/screenshots")
 for screen in ["Main menu","New career"]:
  go(screen)
  await get_tree().process_frame
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png("res://builds/screenshots/"+screen.to_snake_case()+".png")
 GameState.new_career({"name":"Mira Rahman","age":28,"district":"Dhaka","background":0,"traits":["trait_2","trait_5"]},342)
 GameState.create_film({"title":"The Last Ferry","logline":"One river. Two generations. A journey home.","synopsis":"A daughter returns to the river she once left behind.","setting":"Sadarghat","genre":0,"tier":0,"source":0,"rating":"U","theme":"Family","tone":"Hopeful","era":"Present day"})
 for screen in ["Dashboard","Film studio","Release calendar"]:
  go(screen)
  await get_tree().create_timer(.6).timeout
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png("res://builds/screenshots/"+screen.to_snake_case()+".png")
 print("UI_CAPTURE_OK")
 get_tree().quit()

func verify_export() -> void:
 var valid: bool = Verification.run()
 if not valid:push_error("CAREER_VERIFICATION_FAILED")
 get_tree().quit(0 if valid else 1)
