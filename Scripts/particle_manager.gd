extends Node2D
class_name ParticleManager
@export var ptcc: ParticleController

# Continuous Particle
@onready var ground_trail: CPUParticles2D = $TrailParticles
# Continuous scene counterpart
const ground_trail_scene = preload("res://Scenes/Visuals/Particles/trail_particles.tscn")
# Oneshot Particle
@onready var jump_trail: CPUParticles2D = $JumpTrailParticles
@onready var doublejump_trail: Node2D = $DoubleJumpTrail
@onready var explosion: CPUParticles2D = $Explosion
# Oneshot scene counterpart
const jump_trail_scene = preload("res://Scenes/Visuals/Particles/jump_trail_particles.tscn")
const doublejump_trail_scene = preload("res://Scenes/Visuals/Particles/double_jump_trail.tscn")
const explosion_scene = preload("res://Scenes/Visuals/Particles/explosion.tscn")

var particles:= {}
var oneshot_particles:= {}
var particle_scenes:= {}
var oneshot_particle_scenes:= {}
var particle_pool:= {}
var continuous_particle_pool := {
	"ground_trail": [],
}
var continuous_particle_links := {}

func _ready() -> void:
	# Statistics
	Stat.Ptc = self
	
	# Currently active
	particles = {
		ground_trail: "ground_trail",
	}
	oneshot_particles = {
		jump_trail: "jump_trail",
		doublejump_trail: "doublejump_trail",
		explosion: "explosion",
	}
	
	# Scenes
	particle_scenes = {
		"ground_trail": ground_trail_scene,
	}
	oneshot_particle_scenes = {
		"jump_trail": jump_trail_scene,
		"doublejump_trail": doublejump_trail_scene,
		"explosion": explosion_scene,
	}

func _process(delta: float) -> void:
	pass
	#_check_offscreen_particles()

func _check_offscreen_particles():
	for particle in particles: if Stat.is_offscreen(particle):
		set_particle_childs(particle, false)
		particle.hide()
	else: particle.show()
	for particle in oneshot_particles: if Stat.is_offscreen(particle):
		set_particle_childs(particle, false)
		particle.hide()
	else: particle.show()
	for particle in continuous_particle_links: if Stat.is_offscreen(particle):
		set_particle_childs(particle, false)
		particle.hide()
	else: particle.show()

func get_particle(particle_name: String):
	var particle_node = _get_particle_node(particle_name)
	
	if particle_node: 
		if particle_node is CPUParticles2D:
			return particle_node
		else: push_error("Can't return '%s' if it's not 'CPUParticles2D' node." % particle_name)
	else:
		push_error("Particle '%s' not found." % particle_name)
		return null

func emit_particle(particle_name: String, emitting:= true):
	var particle_node = _get_particle_node(particle_name)
	
	if particle_node:
		if particle_node is CPUParticles2D:
			if emitting: particle_node.emitting = true
			else: particle_node.emitting = false
		elif particle_node is Node2D:
			_group_emit_particle(particle_node, emitting)
		else:
			push_error("Particle '%s' are neither 'CPUParticles2D' or 'Node2D' node." % particle_name)
			return null
	else:
		push_error("Particle '%s' not found." % particle_name)
		return null

func _get_particle_node(particle_name: String):
	var particle_node
	var is_one_shot:= true
	
	# Check current particles
	for node in particles:
		if particles[node] == particle_name:
			is_one_shot = false
			if node is CPUParticles2D: if !node.emitting:
				return node
			elif node.get_class() == "Node2D": if !_group_get_longest_particle(node).emitting:
				return node
	
	for node in oneshot_particles:
		if oneshot_particles[node] == particle_name:
			is_one_shot = true
			if node is CPUParticles2D: if !node.emitting:
				return node
			elif node.get_class() == "Node2D": if !_group_get_longest_particle(node).emitting:
				return node
	
	# Instantiate new
	if is_one_shot:
		return _get_particle_instance(particle_name, oneshot_particles)
	else:
		return _get_particle_instance(particle_name, particles)

func _group_get_longest_particle(particle_parent: Node2D) -> CPUParticles2D:
	var max_duration:= 0.0
	var longest_particle: CPUParticles2D
	
	for particle in particle_parent.get_children():
		print(particle)
		if particle is CPUParticles2D and particle.stream and particle.stream.get_length() > max_duration:
			longest_particle = particle
			max_duration = particle.stream.get_length()
	
	if longest_particle: return longest_particle
	else:
		push_error("Where da longest particle u no u NEED one.")
		return null

func _group_emit_particle(particle_parent: Node2D, emitting:= true):
	if particle_parent == null: return
	for particle in particle_parent.get_children():
		if particle is CPUParticles2D:
			if emitting: particle.emitting = true
			else: particle.emitting = false

func _get_particle_instance(particle_name: String, particle_list: Dictionary):
	var new_node
	if particle_scenes.has(particle_name): new_node = particle_scenes[particle_name].instantiate()
	elif oneshot_particle_scenes.has(particle_name): new_node = oneshot_particle_scenes[particle_name].instantiate()
	else: push_error("Particle '%s' not found." % particle_name)
	add_child(new_node)
	particle_list[new_node] = particle_name
	return new_node

func get_or_link_continuous(particle_name: String, obj) -> CPUParticles2D:
	var obj_id = obj.base.id
	var current_pos = obj.global_position
	
	# First, check if this object is already linked
	for particle in continuous_particle_links:
		if continuous_particle_links[particle] == ("%s-%s" % [particle_name, obj_id]):
			particle.global_position = current_pos
			return particle
	
	# Then, try to find a free one
	var free_pool = continuous_particle_pool.get(particle_name, [])
	for particle in free_pool:
		continuous_particle_links[particle] = ("%s-%s" % [particle_name, obj_id])
		free_pool.erase(particle)
		particle.global_position = current_pos
		return particle
	
	# None free? Spawn new
	var scene = particle_scenes.get(particle_name)
	if scene:
		var new_instance = scene.instantiate()
		new_instance.global_position = current_pos
		add_child(new_instance)
		continuous_particle_links[new_instance] = ("%s-%s" % [particle_name, obj_id])
		return new_instance
	
	push_error("No scene found for '%s'" % particle_name)
	return null

func release_continuous_particle(particle_name: String, obj):
	var obj_id = obj.base.id
	for particle in continuous_particle_links.keys():
		if continuous_particle_links[particle] == ("%s-%s" % [particle_name, obj_id]):
			if is_instance_valid(particle):
				particle.emitting = false
				continuous_particle_pool[particle_name].append(particle)
			continuous_particle_links.erase(particle)

func set_particle_childs(node, emitting: bool, visited := {}):
	if node is CPUParticles2D: node.emitting = emitting
	if node in visited:
		return
	visited[node] = true
	
	for child in get_children():
		if child is CPUParticles2D: child.emitting = emitting
		if child.get_children(): set_particle_childs(child, emitting, visited)
