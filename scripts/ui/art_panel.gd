class_name DirectorArt
extends Control
## Replace this resource-facing control to swap all procedural art.
var mode: String = "poster"
var title: String = "THE DIRECTOR"
var tint: Color = Color("5de1c0")
var variant: int = 0
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
 var w: float = size.x
 var h: float = size.y
 draw_rect(Rect2(Vector2.ZERO,size),Color("102630"))
 if mode=="portrait":
  draw_circle(Vector2(w*.5,h*.4),minf(w,h)*.20,Color("cfaa85"))
  draw_circle(Vector2(w*.5,h*.31),minf(w,h)*.20,Color("18202a"))
  draw_circle(Vector2(w*.5,h*.42),minf(w,h)*.17,Color("cfaa85"))
  draw_style_box(_rounded(tint),Rect2(w*.5-minf(w,h)*.34,h*.65,minf(w,h)*.68,h*.5))
  draw_circle(Vector2(w*.44,h*.4),2,Color("102630"))
  draw_circle(Vector2(w*.56,h*.4),2,Color("102630"))
  return
 draw_circle(Vector2(w*.68,h*.28),w*.22,Color(tint,.13))
 draw_circle(Vector2(w*.68,h*.28),w*.15,Color(tint,.16))
 draw_circle(Vector2(w*.68,h*.28),w*.08,Color("efca89"))
 for i in range(13):
  var height: float = h*(.10+float((i*37+variant*13)%17)/80)
  draw_rect(Rect2(i*w/12,h*.69-height,w/12-3,height),Color("203c43"))
  for j in range(3):
   draw_rect(Rect2(i*w/12+5,h*.69-height+8+j*15,3,5),Color(tint,.4))
 draw_colored_polygon(PackedVector2Array([Vector2(0,h*.72),Vector2(w,h*.62),Vector2(w,h*.91),Vector2(0,h*.98)]),Color("18464b"))
 for i in range(12):
  draw_line(Vector2(w*.1+i*13,h*.77+i%3*9),Vector2(w*.38+i*13,h*.77+i%3*9),Color(tint,.3),1)
 draw_rect(Rect2(0,h*.88,w,h*.12),Color("0b171f"))
 var font: Font = ThemeDB.fallback_font
 draw_string(font,Vector2(20,h*.82),title.to_upper().left(26),HORIZONTAL_ALIGNMENT_LEFT,w-40,22,tint)
 draw_string(font,Vector2(20,h*.94),"A STORY WORTH TELLING",HORIZONTAL_ALIGNMENT_LEFT,w-40,11,Color("b7c7c7"))
func _rounded(color: Color) -> StyleBoxFlat:
 var box := StyleBoxFlat.new()
 box.bg_color=color
 box.corner_radius_top_left=35
 box.corner_radius_top_right=35
 return box
