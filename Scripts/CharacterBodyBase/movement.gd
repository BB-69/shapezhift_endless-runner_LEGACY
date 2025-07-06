extends Node
class_name MovementComponent
var char_body: CharacterBody2D

@export var can_move: bool = true
enum MoveMode {Slide, Jump, Fly}
@export var current_move_mode: MoveMode

func _init(set_move_mode:MoveMode = current_move_mode):
	# CharacterBody2D of parent node of THIS node
	if get_parent() is CharacterBody2D: char_body = get_parent()
	
	current_move_mode = set_move_mode
	acceleration = max_speed / max_speed_duration

func _update(delta: float) -> void:
	# If dead
	if !char_body.hp.is_alive:
		char_body.phy.this_speed.x = move_toward(char_body.phy.this_speed.x, 0.0, acceleration * delta)
		char_body.velocity.x = char_body.phy.this_speed.x
		char_body.velocity.y = lerp(char_body.velocity.y, 0.0, 0.5)
		return
	
	if !can_move: return
	# Check current movement behaviour
	if current_move_mode == MoveMode.Slide: _slide_only(delta)
	elif current_move_mode == MoveMode.Jump: _slide_and_jump(delta)
	elif current_move_mode == MoveMode.Fly: _fly_and_slide(delta)
	else: push_error("No movement mode picked.")

# Physics
@export_group("Stats")
@export var max_speed: float = 900
@export var max_speed_duration: float = 0.25
var acceleration: float # Per seconds

var prev_velocity:= []
var direction:= Vector2i(0, 0)

@export var jump_power = -1200.0
var can_jump:= true
var can_double_jump:= true

@export_group("Physics")
@export var apply_friction = false
@export var bounce_factor:= 0.5

func set_friction(new_friction: float, is_horizontal:= true):
	if apply_friction:
		if is_horizontal: char_body.phy.friction.x = new_friction
		else:char_body.phy.friction.y = new_friction
	else: char_body.phy.friction = Vector2.ZERO

# =============== Movement Mode: Slide ===============
func _slide_only(delta):
	# Handle movement/deceleration.
	direction.x = char_body.get_axis("move_left", "move_right")
	
	if char_body.is_on_floor() and direction.x == 0:
		set_friction(char_body.phy.friction_set.x)
	elif direction.x != 0:
		if direction.x != sign(char_body.velocity.x): set_friction(char_body.phy.friction_set.x)
		else: set_friction(0.0)
		char_body.phy.this_speed.x = move_toward(char_body.phy.this_speed.x, direction.x * max_speed, acceleration * delta)
	else:
		set_friction(0.0)
		char_body.phy.this_speed.x = char_body.velocity.x
	
	# Keeps track of previous velocity iterations
	prev_velocity.append(char_body.velocity)
	if prev_velocity.size() > 5: prev_velocity.pop_front()
	
	char_body.velocity.x = char_body.phy.this_speed.x
	char_body.move_and_slide()
	
	# Bouncing off walls
	if char_body.is_on_wall():
		var wall_normal = char_body.get_wall_normal()
		# Only bounce if moving into the wall (dot product negative)
		if char_body.phy.was_on_wall:
			char_body.velocity.x = 0
			char_body.phy.this_speed.x = 0
		elif prev_velocity[0].dot(wall_normal) < 0:
			var bounce_factor = 0.5  # 0 to 1
			var bounce_velocity = prev_velocity[0].bounce(wall_normal) * bounce_factor
			bounce_velocity.y *= 0.7
			
			char_body.velocity = bounce_velocity
			char_body.phy.this_speed.x = bounce_velocity.x





# =============== Movement Mode: Jump ===============
var jump_timer:= 0.0
var jump_cooldown:= 0.05

func _slide_and_jump(delta):
	# Double Jump & Gravity
	if char_body.is_on_wall():
		can_double_jump = true
	
	if !char_body.is_on_floor():
		if char_body.get_input(false)["move_up"] and can_double_jump and !can_jump:
			_jump(true)
			can_double_jump = false
	else:
		can_jump = true
		can_double_jump = true

	# Handle jump
	jump_timer += delta
	if char_body.get_input(true)["move_up"]:
		if can_jump and jump_timer > jump_cooldown:
			jump_timer = 0.0
			can_jump = false
			_jump()
		else:
			char_body.velocity.y += -acceleration * 0.6 * delta
	
	# Slide
	_slide_only(delta)

# Jump
signal jumped
signal double_jumped
func _jump(is_double_jump = false):
	if is_double_jump:
		char_body.velocity.y = jump_power * 1.2
		emit_signal("double_jumped", char_body)
	else:
		char_body.velocity.y = jump_power
	emit_signal("jumped", char_body)





# =============== Movement Mode: Fly ===============
func _fly_and_slide(delta):
	# Handle movement/deceleration.
	direction = Vector2i(
		char_body.get_axis("move_left", "move_right"),
		char_body.get_axis("move_down", "move_up")
	)
	
	if direction.x == 0:
		set_friction(char_body.phy.friction_set.x, true)
	else:
		if direction.x != sign(char_body.velocity.x):
			set_friction(char_body.phy.friction_set.x, true)
		else: set_friction(0.0, true)
		char_body.phy.this_speed.x = move_toward(char_body.phy.this_speed.x, direction.x * max_speed, acceleration * delta)
	
	if direction.y == 0:
		set_friction(char_body.phy.friction_set.y, false)
	else:
		if direction.y != sign(char_body.velocity.y):
			set_friction(char_body.phy.friction_set.y, false)
		else: set_friction(0.0, false)
		char_body.phy.this_speed.y = move_toward(char_body.phy.this_speed.y, direction.y * max_speed, acceleration * delta)
	
	
	# Keeps track of previous velocity iterations
	prev_velocity.append(char_body.velocity)
	if prev_velocity.size() > 5: prev_velocity.pop_front()
	
	char_body.velocity = char_body.phy.this_speed
	char_body.move_and_slide()
	
	
	# Bouncing off floor and ceiling
	if char_body.is_on_floor() or char_body.is_on_ceiling():
		var surface_normal
		if char_body.is_on_floor(): surface_normal = char_body.get_floor_normal()
		elif char_body.is_on_ceiling(): surface_normal = char_body.get_floor_normal()
		
		if char_body.phy.was_on_floor or char_body.phy.was_on_ceiling:
			char_body.velocity.y = 0
			char_body.phy.this_speed.y = 0
		elif prev_velocity[0].dot(surface_normal) < 0:
			var bounce_velocity = prev_velocity[0].bounce(surface_normal) * bounce_factor
			bounce_velocity.x *= 0.7
			
			char_body.velocity = bounce_velocity
			char_body.phy.this_speed.y = bounce_velocity.y
	
	# Bouncing off wall
	if char_body.is_on_wall_only():
		var wall_normal = char_body.get_wall_normal()
		
		if char_body.phy.was_on_wall:
			char_body.velocity.x = 0
			char_body.phy.this_speed.x = 0
		elif prev_velocity[0].dot(wall_normal) < 0:
			var bounce_velocity = prev_velocity[0].bounce(wall_normal) * bounce_factor
			bounce_velocity.y *= 0.7
			
			char_body.velocity = bounce_velocity
			char_body.phy.this_speed.x = bounce_velocity.x
