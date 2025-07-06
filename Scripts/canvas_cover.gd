extends Polygon2D
class_name CameraCanvas

func _ready() -> void:
	# Statistics
	Stat.CameraCover = self
	
	RenderingServer.set_default_clear_color(Color(0.3,0.3,0.3,1))
	if !visible: show()
	color = Color(0,0,0,1)

func _process(delta: float) -> void:
	if !Stat.Camera: return
	
	global_position = Stat.Camera.global_position
	fade_in_canvas()

var faded_in:= false
func fade_in_canvas():
	if faded_in: return
	faded_in = true
	
	color = Color(0,0,0,1)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "color", Color(0,0,0,0), 0.5)

func _on_died(obj):
	fade_out_canvas()

func fade_out_canvas():
	await get_tree().create_timer(1).timeout
	color = Color(0,0,0,0)
	var tween = get_tree().create_tween()
	await tween.tween_property(self, "color", Color(0,0,0,1), 0.5).finished
	
	RenderingServer.set_default_clear_color(Color(0,0,0,1))
