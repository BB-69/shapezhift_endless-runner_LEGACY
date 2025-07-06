extends AIComponent
class_name AITriangle
var char_body: CharacterBody2D

@export var position_padding:= Vector2.ZERO

func _ready() -> void:
	# CharacterBody2D of parent node of THIS node
	if get_parent(): char_body = get_parent()

var frame_timer:= 0.0
var frame_interval:= 0.5
func _update(delta):
	frame_timer += delta
	if frame_timer < frame_interval: return
	frame_timer = 0.0
	frame_interval = randf_range(0.01, 0.3)
	
	if Stat.Player and Stat.Player.hp.is_alive and char_body:
		move_left = Stat.Player.position.x < char_body.position.x + position_padding.x
		move_right = Stat.Player.position.x > char_body.position.x - position_padding.x
		move_up = Stat.Player.position.y > char_body.position.y - position_padding.y
		move_down = Stat.Player.position.y < char_body.position.y + position_padding.y
	else:
		move_left = false
		move_right = false
		move_up = false
		move_down = false
