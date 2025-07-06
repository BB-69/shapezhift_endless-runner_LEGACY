extends Node
class_name ParticleController
var ptc: ParticleManager

func _ready() -> void:
	if get_parent() is ParticleManager: ptc = get_parent()
	else: push_error("Dumb bitch, why u attach 'ParticleController' to smthing else? Bring it back to 'ParticleManager'.")

func _process(delta: float) -> void:
	pass

func _on_damage_dealt(target, damage, is_crit):
	target.aspr.blink(Color(0.9, 0.1, 0, 0.8), 0.3, 0.1)
	return
	var particle = ptc.get_particle("hit")
	particle.global_position = target.global_position
	particle.emitting = true

func _on_jumped(obj):
	var particle = ptc.get_particle("jump_trail")
	particle.global_position = obj.global_position
	particle.emitting = true

func _on_double_jumped(obj):
	var particle = ptc._get_particle_node("doublejump_trail")
	particle.global_position = obj.global_position
	ptc._group_emit_particle(particle)

@export var off_ground_delay:= 0.1
var off_ground_time:= {}
func _on_moving_on_ground(delta, obj):
	var obj_id = obj.base.id
	if !off_ground_time.has(obj_id): off_ground_time[obj_id] = 0.0
	
	var particle = ptc.get_or_link_continuous("ground_trail", obj)
	particle.global_position.x = obj.global_position.x
	var is_moving = abs(obj.velocity.x) > 10.0
	
	if is_moving:
		if obj.is_on_floor():
			off_ground_time[obj_id] = 0.0
			particle.emitting = true
			particle.global_position.y = obj.global_position.y + 64.0
			particle.global_rotation = 0.0
		elif obj.is_on_ceiling():
			off_ground_time[obj_id] = 0.0
			particle.emitting = true
			particle.global_position.y = obj.global_position.y - 64.0
			particle.global_rotation = 180.0
		else:
			off_ground_time[obj_id] += delta
			if off_ground_time[obj_id] < off_ground_delay:
				particle.emitting = true
			else:
				particle.emitting = false
	else:
		particle.emitting = false
		off_ground_time[obj_id] = 0.0

func _on_wind_blowing(delta, obj):
	pass

func _on_platform_hit(delta, obj):
	pass

func _on_died(obj):
	ptc.release_continuous_particle("ground_trail", obj)
	
	off_ground_time.erase(obj.base.id)

func _on_exploded(obj):
	var particle = ptc.get_particle("explosion")
	particle.global_position = obj.global_position
	particle.emitting = true
