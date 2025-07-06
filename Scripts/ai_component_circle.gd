extends AIComponent
class_name AICircle
var char_body: CharacterBody2D

@export var position_padding:= Vector2.ZERO
@export var simulated_velocity:= 1000
@export var simulated_jump_power: Array[float]
@export var arc_segment: Area2D
var arc_segment_pos:= Vector2.ZERO
var arc_segment_global_pos:= Vector2.ZERO
var colliding:= []

var gravity:= Vector2.ZERO
var body_global_position:= Vector2.ZERO
var player_global_position:= Vector2.ZERO

func _ready() -> void:
	# CharacterBody2D of parent node of THIS node
	if get_parent(): char_body = get_parent()





# ==================== PATHFINDING LOGIC SHENANIGANS ==================== #

var frame_timer:= 0.0
var frame_interval:= 0.5
var finding_jump_path:= false
func _process(delta: float) -> void:
	#print(arc_segment.position)
	arc_segment.position = arc_segment_pos
	arc_segment_global_pos = arc_segment.global_position
	colliding = arc_segment.get_overlapping_bodies()
	
	gravity = char_body.get_gravity() * char_body.phy.gravity_multiplier
	body_global_position = char_body.global_position
	player_global_position = Stat.Player.global_position
	
	frame_timer += delta
	if frame_timer < frame_interval: return
	frame_timer = 0.0
	frame_interval = randf_range(0.5, 0.5)
	
	if Stat.Player and !Stat.Player.hp.is_alive:
		find_path_thread.cancel_free()
	if char_body.is_on_floor() and !finding_jump_path:
		finding_jump_path = true
		find_path_thread = Thread.new()
		find_path_thread.start(Callable(self, "find_jump_path"))

var find_path_thread: Thread
var is_gameover:= false

func find_jump_path():
	var possible_jumps: Dictionary = await simulate_jump_arcs()
	var best_jump: Dictionary = await pick_best_jump(possible_jumps)
	if best_jump and !best_jump.is_empty():
		selected_jump = best_jump
		on_navigation = true
	else: finding_jump_path = false

func simulate_jump_arcs() -> Dictionary:
	arc_segment_pos = Vector2.ZERO
	var simulated_jumps:= {}
	var delta_time = pow(10, -6) / 2
	var direction:= [-1, 1]
	
	while simulated_jumps.is_empty(): for jump_power in simulated_jump_power: for dir in direction:
		var velocity = Vector2(simulated_velocity * dir, jump_power)
		var platform_hit:= false
		var last_simulated_position:= body_global_position
		
		while !platform_hit:
			#get_tree().process_frame
			if !colliding.is_empty(): continue
			velocity += gravity * delta_time
			arc_segment_pos += velocity * delta_time
			
			if colliding: for obj in colliding: if obj is TileMapLayer:
				platform_hit = true
				if velocity.y >= 0 and arc_segment_global_pos.y < 0:
					simulated_jumps[arc_segment_global_pos] = [last_simulated_position, dir, jump_power]
				arc_segment_pos = Vector2.ZERO
				break
		
		while !colliding.is_empty(): pass
	#print(simulated_jumps)
	return simulated_jumps

func pick_best_jump(possible_jumps: Dictionary):
	var current_distance = player_global_position.distance_to(body_global_position)
	var min_distance = current_distance
	var best_jump: Dictionary
	
	for land_position in possible_jumps:
		if min_distance > player_global_position.distance_to(land_position):
			min_distance = min(min_distance, player_global_position.distance_to(land_position))
			best_jump[land_position] = possible_jumps[land_position]
	return best_jump





# ==================== AI MOVING LOGIC SHENANIGANS ==================== #
var on_navigation:= false
var selected_jump:= {}

func _update(delta):
	if !on_navigation:
		if Stat.Player and Stat.Player.hp.is_alive and char_body:
			move_left = Stat.Player.position.x < char_body.position.x + position_padding.x
			move_right = Stat.Player.position.x > char_body.position.x - position_padding.x
		else:
			move_left = false
			move_right = false
		move_up = false
	else:
		find_and_move_to_player(selected_jump)

func find_and_move_to_player(selected_jump: Dictionary):
	if selected_jump and !selected_jump.is_empty():
		# selected_jump[arc_segment_global_pos] = [last_simulated_position, dir, jump_power]
		# ------------------------------------- to -----------------------------------------
		# selected_jump[final_pos] = [last_pos, dir, jump_power]
		var final_pos 	= selected_jump.keys()[0]
		var last_pos 	= selected_jump.values()[0][0]
		var dir 		= selected_jump.values()[0][1]
		var jump_power 	= selected_jump.values()[0][2]
		
		var prepare_to_jump:= false
		var find_new_path:= false
		while !find_new_path and char_body.is_on_floor() and player_global_position.distance_to(body_global_position) > player_global_position.distance_to(final_pos):
			# -1 or 1
			# -1 (left) if 'final_pos' is on the left of 'last_pos'
			# 1 (right) if 'final_pos' is on the right of 'last_pos'
			var jumping_dir = sign(final_pos.x - last_pos.x)
			
			# Default: Jumping to right
			if !prepare_to_jump and body_global_position.x * jumping_dir > last_pos.x * jumping_dir and char_body.is_on_floor():
				move_left = jumping_dir > 0
				move_right = jumping_dir < 0
			elif char_body.is_on_floor() and body_global_position.x * jumping_dir < last_pos.x * jumping_dir:
				prepare_to_jump = true
				move_left = jumping_dir < 0 and abs(char_body.velocity.x) < simulated_velocity
				move_right = jumping_dir > 0 and abs(char_body.velocity.x) < simulated_velocity
			else:
				char_body.mov.jump_power = jump_power * 1.05
				move_left = false
				move_right = false
				move_up = true
				while !char_body.is_on_floor(): await get_tree().process_frame
				if char_body.global_position.y < final_pos.y:
					prepare_to_jump = false
				else:
					find_new_path = true
			
			await get_tree().process_frame
	
	selected_jump = {}
	finding_jump_path = false
	on_navigation = false
