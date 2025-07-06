extends AnimatedSprite2D
class_name AnimatedSpriteComponent
var char_body: CharacterBody2D

@export_group("SpriteEdge")
enum Shape {Rectangle, Circle, Triangle}
@export var current_shape: Shape

@export_group("SpriteTint")
@export var tint: bool
@export var target_color: Color = Color(0, 0, 0)
@export var tint_color: Color = Color(1, 1, 1)

@export_group("Animation")
@export var update_animation:= true
var idle_stretch
var stretch

const blink_shader = preload("res://Shaders/blink.gdshader")
const tint_shader = preload("res://Shaders/tint.gdshader")

func _ready() -> void:
	# CharacterBody2D of parent node of THIS node
	if get_parent() is CharacterBody2D: char_body = get_parent()
	
	if !sprite_frames: push_error("Please assign 'Sprite Frames' in 'Animation'")
	sprite_init()
	if tint: sprite_tint_init()
	
	idle_stretch = transform.get_scale() * 0.95
	stretch = idle_stretch
	stretch.x *= 1.2
	stretch.y *= 0.9

func _process(delta: float) -> void:
	if !char_body: return
	
	if update_animation: _visualize_sprite(delta)

var sprite_initiated:= false
func sprite_init():
	if sprite_initiated: return
	sprite_initiated = true
	
	var mesh_instance:= MeshInstance2D.new()
	var mesh:= ArrayMesh.new()
	var range:= 64
	
	match current_shape:
		Shape.Rectangle:
			var vertices = PackedVector2Array([
				Vector2(-range, -range),
				Vector2(range, -range),
				Vector2(range, range),
				Vector2(-range, range)
			])
			var indices = PackedInt32Array([
				0, 1, 2,
				2, 3, 0
			])
			var colors = PackedColorArray([Color.BLACK, Color.BLACK, Color.BLACK, Color.BLACK])
			
			var arrays = []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = vertices
			arrays[Mesh.ARRAY_INDEX] = indices
			arrays[Mesh.ARRAY_COLOR] = colors
			
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		Shape.Circle:
			var num_segments = 32
			var radius = range
			
			var vertices = PackedVector2Array()
			var indices = PackedInt32Array()
			var colors = PackedColorArray()
			
			vertices.append(Vector2(0, 0))
			colors.append(Color.BLACK)
			
			for i in range(num_segments + 1):  # +1 to close the circle
				var angle = 2.0 * PI * i / num_segments
				var x = radius * cos(angle)
				var y = radius * sin(angle)
				vertices.append(Vector2(x, y))
				colors.append(Color.BLACK)
			
			# Create triangles (fan from the center)
			for i in range(1, num_segments + 1):
				indices.append(0)  # center vertex
				indices.append(i)
				indices.append(i + 1 if i < num_segments else 1)  # wrap around~
			
			# Put it all together
			var arrays = []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = vertices
			arrays[Mesh.ARRAY_INDEX] = indices
			arrays[Mesh.ARRAY_COLOR] = colors
			
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		Shape.Triangle:
			var vertices = PackedVector2Array()
			var colors = PackedColorArray()
			
			var point:= Vector2(0, -range*1.2)
			var offset:= Vector2(0, 640/range)
			for i in range(3):
				vertices.append(point + offset)
				colors.append(Color.BLACK)
				point = point.rotated(PI*2.0/3.0)
			
			var arrays = []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = vertices
			arrays[Mesh.ARRAY_COLOR] = colors
			
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	mesh_instance.mesh = mesh
	mesh_instance.z_index = -1
	mesh_instance.scale *= 1.1
	add_child(mesh_instance)

func sprite_tint_init():
	var shader_material = ShaderMaterial.new()
	shader_material.shader = tint_shader
	material = shader_material
	
	material.set_shader_parameter("target_color", target_color)
	material.set_shader_parameter("tint_color", tint_color)
	
	self.material = material

func _visualize_sprite(delta):
	var thisScale
	var thisRotation: float
	var thisPosition: Vector2
	
	if char_body.is_on_floor():
		thisScale = lerp(idle_stretch, stretch, abs(char_body.velocity.x)/char_body.mov.max_speed)
		thisRotation = 0
		thisPosition = lerp(Vector2.ZERO, Vector2.DOWN * 3, abs(char_body.velocity.x)/char_body.mov.max_speed)
	else:
		thisScale = lerp(idle_stretch, stretch, abs(char_body.velocity.length())/char_body.mov.max_speed)
		thisRotation = char_body.velocity.angle()
	
	scale = lerp(scale, thisScale, 10 * delta)
	if char_body:
		if !char_body.get_input(true)["move_up"] or (!char_body.is_on_floor() and char_body.velocity.length() > 0.1):
			rotation = thisRotation
	position = thisPosition

var blink_delay: Timer
var blink_tween: Tween
func blink(color:Color, duration:float=0.5, delay:float=0.0):
	if blink_delay and !blink_delay.is_stopped(): blink_delay.stop()
	if blink_tween: blink_tween.kill()
	
	var shader_material = ShaderMaterial.new()
	shader_material.shader = blink_shader
	shader_material.set_shader_parameter("blink_color", color)
	material = shader_material
	
	if delay > 0:
		_set_blink(1)
		blink_delay = Timer.new()
		add_child(blink_delay)
		blink_delay.one_shot = true
		blink_delay.start(delay)
		await blink_delay.timeout
	
	blink_tween = get_tree().create_tween()
	blink_tween.tween_method(_set_blink, 1.0, 0.0, duration)
func _set_blink(value): material.set_shader_parameter("blink_intensity", value)

func _on_double_jumped(obj):
	blink(Color(1, 1, 1), 0.2, 0.1)
