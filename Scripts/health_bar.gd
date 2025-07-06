extends Node2D
class_name HealthBar
var char_body: CharacterBody2D
@export var hp: HealthComponent

@onready var back_bar: Polygon2D = $Background
@onready var progress_bar: ProgressBar = $ProgressBar
@export var value_smoothing:= 10.0
@export var in_offset: Vector2
@export var offset:= Vector2.ZERO

func _ready() -> void:
	# CharacterBody2D of parent node of THIS node
	if get_parent() is CharacterBody2D: char_body = get_parent()
	
	progress_bar_init(0, 1, 0)

func _process(delta: float) -> void:
	back_bar_init()
	progress_bar_appearance(delta)
	
	

var target_back_bar_size
func back_bar_init():
	back_bar.global_position = char_body.global_position + offset
	
	target_back_bar_size = abs(progress_bar.size)
	target_back_bar_size.x += 6
	target_back_bar_size.y += 6
	
	var plane:= Vector2.UP + Vector2.RIGHT
	for point in back_bar.polygon:
		plane.rotated(PI/2)
		point = Vector2(target_back_bar_size.x * sign(plane.x), target_back_bar_size.y * sign(plane.y))

var target_progress_bar_color:= Color(1, 1, 1, 1)
func progress_bar_appearance(delta):
	progress_bar.global_position = char_body.global_position + in_offset + offset -progress_bar.size/2
	
	var previous_value:= progress_bar.value
	progress_bar.value = lerp(progress_bar.value, 100*hp.current_health/hp.max_health, value_smoothing * delta)
	
	var change_speed:float = (progress_bar.value - previous_value) / delta
	var max_speed:float = value_smoothing * delta * 300
	var red:float = lerp(0.9, 0.0, clamp(change_speed/max_speed, 0.0, 1.0))
	var green:float = lerp(0.0, 0.9, clamp(change_speed/max_speed, -1.0, 0.0) + 1.0)
	
	if progress_bar_gradient:
		target_progress_bar_color = lerp(target_progress_bar_color, Color(red, green, 0), value_smoothing * delta)
		progress_bar_gradient.set_color(0, target_progress_bar_color)

var progress_bar_gradient: Gradient
func progress_bar_init(r:float, g:float, b:float):
	# Step 1: Clone the StyleBoxTexture
	var original_fill = progress_bar.get("theme_override_styles/fill") as StyleBoxTexture
	var custom_fill = original_fill.duplicate() as StyleBoxTexture

	# Step 2: Clone the GradientTexture and its Gradient
	var original_texture = custom_fill.texture as Texture
	var custom_texture = original_texture.duplicate() as Texture
	var custom_gradient = original_texture.gradient.duplicate()
	progress_bar_gradient = custom_gradient

	custom_texture.gradient = custom_gradient
	custom_fill.texture = custom_texture

	# Step 3: Assign the cloned StyleBoxTexture back to the ProgressBar
	progress_bar.add_theme_stylebox_override("fill", custom_fill)

	# Step 4: Now you can change the colors separately
	custom_gradient.set_color(0, Color(r,g,b))
