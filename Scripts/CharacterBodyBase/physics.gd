extends Node
class_name PhysicsComponent
var char_body: CharacterBody2D
@export var mass:= 1.0

signal moving_on_ground
signal wind_blowing
signal platform_hit

func _init():
	if get_parent(): char_body = get_parent()

func _update(delta: float) -> void:
	_check_just_landed(delta)
	_check_collision()
	_apply_physics(delta)
	_check_fell_out_of_the_world()

# Check just landed on the floor/ceiling
var was_on_floor	:= false # Previous iteration of is_on_[platform]()
var was_on_ceiling	:= false
var was_on_wall		:= false
var just_landed_floor	:= false # Variable for "just" landed conditions
var just_landed_ceiling	:= false
var just_landed_wall	:= false
var just_takeoff_floor	:= false # Variable for "just" take-off conditions
var just_takeoff_ceiling:= false
var just_takeoff_wall	:= false
func _check_just_landed(delta):
	just_landed_floor = !was_on_floor and char_body.is_on_floor()
	just_takeoff_floor = was_on_floor and !char_body.is_on_floor()
	was_on_floor = char_body.is_on_floor()
	just_landed_ceiling = !was_on_ceiling and char_body.is_on_ceiling()
	just_takeoff_ceiling = was_on_ceiling and !char_body.is_on_ceiling()
	was_on_ceiling = char_body.is_on_ceiling()
	just_landed_wall = !was_on_wall and char_body.is_on_wall()
	just_takeoff_wall = was_on_wall and !char_body.is_on_wall()
	was_on_wall = char_body.is_on_wall()
	
	emit_signal("platform_hit", delta, char_body)

# Check collision *all around* the body
@export var hurtbox: Area2D
var colliding:= []
func _check_collision():
	if hurtbox: colliding = hurtbox.get_overlapping_bodies()
	else: push_error("No hurtbox assigned.")

@export_group("Physics")
@export var friction_set:= Vector2(5.0, 5.0)
var friction:= friction_set
@export var gravity_multiplier:= 1.0

var this_speed:= Vector2.ZERO
func _apply_physics(delta):
	var move_mode = char_body.mov.current_move_mode
	if move_mode == char_body.mov.MoveMode.Slide or move_mode == char_body.mov.MoveMode.Jump:
		emit_signal("moving_on_ground", delta, char_body)
		# Apply gravity
		if !char_body.is_on_floor():
			char_body.velocity += char_body.get_gravity() * delta * gravity_multiplier
		# Apply friction when collide with others
		elif !colliding.is_empty() and char_body.velocity.length() > 0 and friction.x != 0:
			this_speed.x = lerp(this_speed.x, 0.0, friction.x * delta)
		
		char_body.velocity.x = this_speed.x
	
	elif move_mode == char_body.mov.MoveMode.Fly:
		# Apply air friction
		if abs(char_body.velocity.x) > 0 and friction.x != 0:
			this_speed.x = lerp(this_speed.x, 0.0, friction.x * delta)
		if abs(char_body.velocity.y) > 0 and friction.y != 0:
			this_speed.y = lerp(this_speed.y, 0.0, friction.y * delta)
		
		char_body.velocity = this_speed
	
	emit_signal("wind_blowing", delta, char_body)

func _check_fell_out_of_the_world():
	if char_body.global_position.y > 0: char_body.hp.is_alive = false
