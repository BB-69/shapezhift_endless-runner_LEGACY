extends AIComponent
class_name AISquare
var char_body: CharacterBody2D

func _ready() -> void:
	# CharacterBody2D of parent node of THIS node
	if get_parent(): char_body = get_parent()

var frame_timer:= 0.0
var frame_interval:= 0.5
func _update(delta):
	frame_timer += delta
	if frame_timer < frame_interval: return
	frame_timer = 0.0
	frame_interval = randf_range(0.01, 0.5)
	
	if Stat.Player and Stat.Player.hp.is_alive and char_body:
		move_left = Stat.Player.position.x < char_body.position.x
		move_right = Stat.Player.position.x > char_body.position.x
	else:
		move_left = false
		move_right = false
