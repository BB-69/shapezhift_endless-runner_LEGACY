extends MeshInstance2D

@export var delay_time: float = 0.5
@export var fade_time: float = 0.5
var time_passed = 0.0

var pos
var alpha:= 1.0

enum Trail {ShadowTrail, Mask}
var trail_role: Trail
var sprite

enum Shape {Circle, Rectangle}
var current_shape: Shape
var shapes:= {
	Shape.Circle: SphereMesh.new(),
	Shape.Rectangle: QuadMesh.new(),
}

func _initialize(new_sprite, set_trail_role: Trail, set_current_shape: Shape):
	sprite = new_sprite
	trail_role = set_trail_role
	current_shape = set_current_shape
	mesh_init()

func _ready() -> void:
	pos = global_position

func _process(delta: float) -> void:
	match trail_role:
		Trail.ShadowTrail:
			global_position = pos
		Trail.Mask:
			position = Vector2.ZERO
			mesh_init()
		_: push_error("Please initialize 'trail_role'.")
	
	mesh_init()
	
	modulate.a = alpha
	time_passed += delta
	if time_passed < delay_time: return
	
	alpha = 1 - ((time_passed - delay_time) / fade_time)
	if alpha <= 0:
		queue_free()

func mesh_init():
	mesh = shapes[current_shape]
	match current_shape:
		Shape.Circle:
			global_scale = sprite.global_scale * 128
		Shape.Rectangle:
			global_scale = sprite.global_scale * 128
		_: push_error("Please initialize 'current_shape'.")
