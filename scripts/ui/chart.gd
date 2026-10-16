class_name BoxOfficeChart
extends Control
var history: Array = []
func _ready() -> void:
 custom_minimum_size=Vector2(400,230)
 mouse_filter=Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
 var area := Rect2(55,24,size.x-85,size.y-60)
 var font: Font = ThemeDB.fallback_font
 var highest: float = 1
 for point in history:
  highest=maxf(highest,float(point.gross))
 for i in range(5):
  var y: float = area.end.y-area.size.y*i/4.0
  draw_line(Vector2(area.position.x,y),Vector2(area.end.x,y),Color("28404a"))
  draw_string(font,Vector2(0,y+4),"%.0f"%(highest*i/4.0),HORIZONTAL_ALIGNMENT_LEFT,48,12,Color("8fa6ae"))
 if history.is_empty():
  draw_string(font,Vector2(75,110),"Your opening weekend is still ahead.",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("8fa6ae"))
  return
 var previous := Vector2.ZERO
 for i in range(history.size()):
  var x: float = area.position.x+area.size.x*(i+.5)/8
  var y: float = area.end.y-area.size.y*float(history[i].gross)/highest
  draw_rect(Rect2(x-12,y,24,area.end.y-y),Color("24524f"))
  var p := Vector2(x,y)
  if i>0:
   draw_line(previous,p,Color("65dfbf"),3,true)
  draw_circle(p,4,Color("65dfbf"))
  draw_string(font,Vector2(x-5,area.end.y+23),str(i+1),HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("8fa6ae"))
  previous=p
