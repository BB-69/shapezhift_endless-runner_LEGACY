extends Node2D
class_name AfterTrailComponent
var char_body

# Assign either if you have Sprite2D or AnimatedSprite2D
var sprite
@export var static_sprite: Sprite2D
@export var animated_sprite: AnimatedSprite2D

const fading_trail = preload("res://Scenes/Visuals/Particles/trail_instance.tscn")
@export var fading_trail_interval = 0.005
var fading_trail_timer := 0.0

func _ready() -> void:
	# CharacterBody2D of parent node of THIS node
	if get_parent() is CharacterBody2D: char_body = get_parent()
	# Sprite
	if static_sprite: sprite = static_sprite
	elif animated_sprite: sprite = animated_sprite
	else: push_error("Please assign either 'Sprite2D' or 'AnimatedSprite2D' in the inspector")

func _process(delta: float) -> void:
	if char_body.base.is_player and char_body.hp.is_alive:
		fading_trail_timer += delta
		if fading_trail_timer >= fading_trail_interval:
			fading_trail_timer = 0.0
			_generate_after_trail(delta)

func _generate_after_trail(delta):
	var trail = fading_trail.instantiate()
	trail._initialize(sprite, trail.Trail.ShadowTrail, trail.Shape.Circle)
	
	$FadingTrails.add_child(trail)
	trail.global_position = sprite.global_position
	trail.rotation = sprite.rotation
	trail.z_index = -5

func after_trail_delay(delay: float):
	fading_trail_timer = -delay
