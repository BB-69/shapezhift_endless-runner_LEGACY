extends CharacterBody2D
class_name PlayerClass
@export var base: BaseComponent
@export var aspr: AnimatedSpriteComponent
@export var spr: Array[Node]
@export var col: Array[CollisionShape2D]
@export var phy: PhysicsComponent
@export var mov: MovementComponent
@export var hp: HealthComponent
@export var dmg: DamageComponent
@export var aft: AfterTrailComponent

# Inputs
func get_input(continuous_press:bool):
	match continuous_press:
		true: return {
			"move_left"	: Input.is_action_pressed("Move-Left"),
			"move_right": Input.is_action_pressed("Move-Right"),
			"move_up"	: Input.is_action_pressed("Move-Up"),
		}
		false: return {
			"move_left"	: Input.is_action_just_pressed("Move-Left"),
			"move_right": Input.is_action_just_pressed("Move-Right"),
			"move_up"	: Input.is_action_just_pressed("Move-Up"),
		}
		_: return null

func get_axis(input1:String, input2:String) -> int:
	var axis:= 0
	if get_input(true)[input1]: axis -= 1
	if get_input(true)[input2]: axis += 1
	return axis





func _ready() -> void:
	base._init("player")
	phy._init()
	mov._init()
	
	_init_statics()

func _physics_process(delta: float) -> void:
	_connect_signals()
	
	for collider in col: collider.set_deferred("disabled", !hp.is_alive)
	
	phy._update(delta)
	mov._update(delta)

func _visibility(visible: bool):
	for object in spr:
		object.visible = visible





# =============== Statics ===============
func _init_statics():
	Stat.Player = self

func _update_statics():
	_connect_signals()

var signal_connected:= false
func _connect_signals():
	if signal_connected or !(Stat.Aud and Stat.Ptc and Stat.CameraCover): return
	signal_connected = true
	
	mov.connect("double_jumped", Callable(aspr, "_on_double_jumped"))
	
	phy.connect("moving_on_ground", Callable(Stat.Aud.audc, "_on_moving_on_ground"))
	phy.connect("wind_blowing", Callable(Stat.Aud.audc, "_on_wind_blowing"))
	phy.connect("platform_hit", Callable(Stat.Aud.audc, "_on_platform_hit"))
	mov.connect("jumped", Callable(Stat.Aud.audc, "_on_jumped"))
	mov.connect("double_jumped", Callable(Stat.Aud.audc, "_on_double_jumped"))
	hp.connect("died", Callable(Stat.Aud.audc, "_on_died"))
	hp.connect("exploded", Callable(Stat.Aud.audc, "_on_exploded"))
	dmg.connect("damage_dealt", Callable(Stat.Aud.audc, "_on_damage_dealt"))
	
	phy.connect("moving_on_ground", Callable(Stat.Ptc.ptcc, "_on_moving_on_ground"))
	mov.connect("jumped", Callable(Stat.Ptc.ptcc, "_on_jumped"))
	mov.connect("double_jumped", Callable(Stat.Ptc.ptcc, "_on_double_jumped"))
	hp.connect("died", Callable(Stat.Ptc.ptcc, "_on_died"))
	hp.connect("exploded", Callable(Stat.Ptc.ptcc, "_on_exploded"))
	dmg.connect("damage_dealt", Callable(Stat.Ptc.ptcc, "_on_damage_dealt"))
	
	hp.connect("gameover", Callable(Stat, "_on_gameover"))
	
	hp.connect("died", Callable(Stat.CameraCover, "_on_died"))
