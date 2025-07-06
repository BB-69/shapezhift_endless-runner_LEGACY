extends Camera2D
class_name CameraComponent

@export var pos_smoothing:= 10.0
var target_pos:= Vector2.ZERO

@export var panning_speed:= 1000.0

func _process(delta: float) -> void:
	Stat.Camera = get_viewport().get_camera_2d()
	Stat.ScreenSize = Vector2(
		get_viewport_rect().size.x * (0.5/zoom.x),
		get_viewport_rect().size.y * (0.5/zoom.y)
	)
	
	if panning:
		var direction = (get_global_mouse_position() - global_position).normalized()
		target_pos += direction * panning_speed * delta
	elif Stat.Player: target_pos = Stat.Player.global_position
	target_pos.y = min(target_pos.y, -Stat.ScreenSize.y/2)
	global_position = lerp(global_position, target_pos, pos_smoothing * delta)

var panning:= false
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 1:
				pass
			elif event.button_index == 2:
				panning = true
		else:
			if event.button_index == 1:
				pass
			elif event.button_index == 2:
				panning = false
