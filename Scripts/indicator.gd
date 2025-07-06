extends Node2D
class_name Indicator
var obj_indicator: ObjIndicator
var target: CharacterBody2D

func _ready() -> void:
	if get_parent(): obj_indicator = get_parent()

var target_found:= false
func _process(delta: float) -> void:
	initialize_sprite()
	if !(target and target.hp.is_alive):
		hide()
		if target_found: self_remove()
		return
	else:
		show()
		target_found = true
	
	
	if obj_indicator.is_off_screen(target.global_position):
		global_position = obj_indicator.get_clamped_position(target.global_position)
		
		arrow_sprite.global_position = get_clamped_position_arrow(target.global_position)
		arrow_sprite.global_rotation = get_direction_angle(global_position, target.global_position)
	else:
		self_remove()

var sprite
func initialize_sprite():
	if $Sprite: sprite = $Sprite
	else: push_error("'Sprite2D' or 'AnimatedSprite2D' node not found in children")
	sprite.scale = Vector2(0.5, 0.5)

@onready var arrow_sprite:= $ArrowSprite
@export var arrow_padding := 150 # Lil space from edge
func get_clamped_position_arrow(pos: Vector2) -> Vector2:
	var center = global_position
	var offset = pos - center
	var dist = offset.length()

	offset = offset.normalized() * arrow_padding
	return center + offset

func get_direction_angle(from: Vector2, to: Vector2) -> float:
	return (to - from).angle()

func self_remove():
	obj_indicator.remove_target(target)
	queue_free()
