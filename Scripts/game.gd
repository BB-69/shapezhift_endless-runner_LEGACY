extends Node2D
class_name GameManager

@export var can_spawn: bool = true

const square = preload("res://Scenes/Entities/square.tscn")
const triangle = preload("res://Scenes/Entities/triangle.tscn")

func _process(delta: float) -> void:
	if Stat.Player and !Stat.Player.hp.is_alive: return
	
	if can_spawn:
		spawn_enemy(delta)

var spawn_timer:= 0.0
var spawn_interval:= 2.0
func spawn_enemy(delta):
	spawn_timer += delta
	if spawn_timer < spawn_interval: return
	spawn_timer = 0.0
	spawn_interval = randf_range(2.5, 4.5)
	
	var object
	var random_enemy_chance = randf_range(0, 60)
	if random_enemy_chance > 30: object = square.instantiate()
	elif random_enemy_chance < 30: object = triangle.instantiate()
	
	object.global_position = Vector2(random_position())
	add_child(object)

func random_position() -> Vector2:
	var random_pos: Vector2
	
	if randf() > 0.4:
		random_pos.x = randf_range(Stat.Player.global_position.x-2560, Stat.Player.global_position.x+2560)
		random_pos.y = -3780
	else:
		random_pos.x = Stat.Player.global_position.x + 2560*sign(randf() - 0.5)
		random_pos.y = randf_range(-3780, 0)
	
	return random_pos
