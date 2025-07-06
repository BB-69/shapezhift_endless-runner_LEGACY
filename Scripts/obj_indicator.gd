extends Node2D
class_name ObjIndicator

const indicator = preload("res://Scenes/Game/indicator.tscn")
var camera_pos: Vector2
var screen_size: Vector2
var current_targets:= []

func _process(delta: float) -> void:
	for enemy in Stat.Enemy:
		if is_off_screen(enemy.position) and !current_targets.has(enemy):
			current_targets.append(enemy)
			instantiate_indicator(enemy)

func remove_target(target):
	current_targets.erase(target)

func instantiate_indicator(new_target: CharacterBody2D):
	var new_sprite
	for child in new_target.get_children():
		if child.name == "AnimatedSprite" or child.name == "Sprite":
			var new_indicator = indicator.instantiate()
			new_indicator.target = new_target
			new_sprite = child.duplicate()
			new_sprite.name = "Sprite"
			new_indicator.add_child(new_sprite)
			add_child(new_indicator)
			return
	push_error("'Sprite2D' or 'AnimatedSprite2D' node not found in '%s' children." % new_target)

func is_off_screen(pos: Vector2) -> bool:
	return abs(pos.x - Stat.Camera.global_position.x) > Stat.ScreenSize.x or abs(pos.y - Stat.Camera.global_position.y) > Stat.ScreenSize.y

@export var padding := 120  # Lil space from edge
func get_clamped_position(pos: Vector2) -> Vector2:
	return Vector2(
		clamp(pos.x, Stat.Camera.global_position.x + padding - Stat.ScreenSize.x, Stat.Camera.global_position.x + Stat.ScreenSize.x - padding),
		clamp(pos.y, Stat.Camera.global_position.y + padding - Stat.ScreenSize.y, Stat.Camera.global_position.y + Stat.ScreenSize.y - padding)
	)
