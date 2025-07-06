extends CharacterBody2D
class_name Square
@export var base: BaseComponent
@export var aspr: AnimatedSpriteComponent
@export var spr: Array[Node]
@export var col: Array[CollisionShape2D]
@export var phy: PhysicsComponent
@export var mov: MovementComponent
@export var hp: HealthComponent
@export var dmg: DamageComponent
@export var ai: Node
@export var aft: AfterTrailComponent

# Inputs
func get_input(continuous_press:bool):
	match continuous_press:
		true: return {
			"move_left"	: ai.get_action("move_left"),
			"move_right": ai.get_action("move_right"),
			"move_up"	: ai.get_action("move_up"),
		}
		false: return {
			"move_left"	: ai.get_action_just("move_left"),
			"move_right": ai.get_action_just("move_right"),
			"move_up"	: ai.get_action_just("move_up"),
		}
		_: return null

func get_axis(input1:String, input2:String) -> int:
	var axis:= 0
	if get_input(true)[input1]: axis -= 1
	if get_input(true)[input2]: axis += 1
	return axis





func _ready() -> void:
	base._init("enemy")
	phy._init()
	mov._init()
	
	_init_statics()

func _physics_process(delta: float) -> void:
	_update_statics()
	
	for collider in col: collider.set_deferred("disabled", !hp.is_alive)
	
	if !hp.is_alive: return
	if global_position.y > 128: hp.is_alive = false
	
	ai._update(delta)
	phy._update(delta)
	mov._update(delta)

func _visibility(visible: bool):
	for object in spr:
		object.visible = visible





# =============== Statics ===============
func _init_statics():
	Stat.Enemy.append(self)

func _update_statics():
	_connect_signals()

var signal_connected:= false
func _connect_signals():
	if signal_connected or !Stat.Aud: return
	signal_connected = true
	
	phy.connect("moving_on_ground", Callable(Stat.Aud.audc, "_on_moving_on_ground"))
	phy.connect("platform_hit", Callable(Stat.Aud.audc, "_on_platform_hit"))
	hp.connect("died", Callable(Stat.Aud.audc, "_on_died"))
	hp.connect("exploded", Callable(Stat.Aud.audc, "_on_exploded"))
	dmg.connect("damage_dealt", Callable(Stat.Aud.audc, "_on_damage_dealt"))
	
	phy.connect("moving_on_ground", Callable(Stat.Ptc.ptcc, "_on_moving_on_ground"))
	hp.connect("died", Callable(Stat.Ptc.ptcc, "_on_died"))
	hp.connect("exploded", Callable(Stat.Ptc.ptcc, "_on_exploded"))
	dmg.connect("damage_dealt", Callable(Stat.Ptc.ptcc, "_on_damage_dealt"))
