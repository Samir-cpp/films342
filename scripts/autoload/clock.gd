extends Node
var paused: bool = true
var speed: int = 1
var elapsed: float = 0
func _process(delta: float) -> void:
 if paused or GameState.state.is_empty() or GameState.state.get("retired",false):
  return
 elapsed += delta*speed
 if elapsed>=4:
  elapsed=0
  GameState.advance_week()
  if not GameState.state.get("pending_event",{}).is_empty():
   paused=true
