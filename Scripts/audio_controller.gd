extends Node
class_name AudioController
var aud: AudioManager

func _ready() -> void:
	if get_parent() is AudioManager: aud = get_parent()
	else: push_error("Dumb fuck, why u attach 'AudioController' to smthing else? Bring it back to 'AudioManager'.")

func _process(delta: float) -> void:
	pass

func _on_damage_dealt(target, damage, is_crit):
	var sound = aud.get_sound("hit")
	sound.global_position = target.global_position
	sound.play()

func _on_jumped(obj):
	var sound = aud.get_sound("whoosh")
	sound.global_position = obj.global_position
	sound.play()

func _on_double_jumped(obj):
	var sound = aud._get_sound_node("whoosh_2")
	sound.global_position = obj.global_position
	aud._group_play_sound(sound)

func _on_moving_on_ground(delta, obj):
	var max_speed = obj.mov.max_speed
	
	var target_volume: float
	var audio_smooth = 20.0 * delta
	var sound = aud.get_or_link_continuous("white_noise", obj)
	sound.global_position = obj.global_position
	
	if obj.velocity.length() != 0:
		if !sound.playing: sound.play()
	else: sound.stop()
	
	if obj.is_on_floor():
		target_volume = lerp(-50, -15, clamp(abs(obj.velocity.x), 0, max_speed) / float(max_speed))
	else:
		target_volume = -100
	
	if sound.volume_db > 0: sound.stop() # Prevent earrape lol
	sound.volume_db = lerp(sound.volume_db, target_volume, audio_smooth)

func _on_wind_blowing(delta, obj):
	var max_speed = obj.mov.max_speed
	
	var target_volume: float
	var audio_smooth = 20.0 * delta
	var sound = aud.get_or_link_continuous("wind_gust", obj)
	sound.global_position = obj.global_position
	
	if true:
		if !sound.playing: sound.play()
	else: sound.stop()
	
	if !obj.is_on_floor():
		target_volume = lerp(-10, 10, clamp(abs(obj.velocity.y), 0, max_speed*2) / float(max_speed*2))
	else:
		target_volume = -10
	
	if sound.volume_db > 15: sound.stop()
	sound.volume_db = lerp(sound.volume_db, target_volume, audio_smooth/4)

func _on_platform_hit(delta, obj):
	var max_speed = obj.mov.max_speed
	
	var target_volume: float
	var audio_smooth = 20.0 * delta
	var sound = aud.get_sound("fell_on_the_ground")
	sound.global_position = obj.global_position
	
	var max_velocity:= Vector2.ZERO
	for vel in obj.mov.prev_velocity:
		if max_velocity.length() < vel.length():
			max_velocity = vel
	
	if obj.phy.just_landed_floor and max_velocity.length() > 1000.0:
		target_volume = lerp(-15, 20, clamp(max_velocity.y - 1000.0, 0.0, 3000.0) / 3000.0)
	elif obj.phy.just_landed_ceiling and max_velocity.length() > 250.0:
		target_volume = lerp(-15, 20, clamp(max_velocity.y - 250.0, 0.0, 2500.0) / 2500.0)
	elif obj.phy.just_landed_wall and max_velocity.length() > 500.0:
		target_volume = lerp(-15, 20, clamp(max_velocity.x - 500.0, 0.0, 3000.0) / 3000.0)
	
	else: target_volume = -100
	if sound.volume_db > 5: sound.stop()
	sound.volume_db = target_volume
	sound.play()

func _on_died(obj):
	aud.release_continuous_sound("white_noise", obj)

func _on_exploded(obj):
	var sound = aud._get_sound_node("explosion")
	sound.global_position = obj.global_position
	aud._group_play_sound(sound)
