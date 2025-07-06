extends Node
class_name HealthComponent
var char_body: CharacterBody2D

@export var _current_health:= 100.0
var current_health:
	get: return _current_health
	set(value): _current_health = min(value, max_health)
@export var max_health:= 100.0
@export var is_alive:= true

func _ready() -> void:
	# CharacterBody2D of parent node of THIS node
	if get_parent() is CharacterBody2D: char_body = get_parent()

func _process(delta: float) -> void:
	if current_health <= 0:
		is_alive = false
		die()
		return
	else: is_alive = true
	if !is_alive:
		current_health = 0
		die()
		return
	
	if char_body.base.tag == "player": regen(delta, 10)
	if char_body.base.tag == "enemy":
		return
		regen(delta, -10)

func heal(amount: float):
	current_health += amount

func apply_damage(amount: float):
	current_health -= amount
	
	if char_body.aft: char_body.aft.after_trail_delay(0.5)

var regen_timer:= 0.0
var regen_interval:= 1.0
var regenerating:= false
func regen(delta, rate: float, interval: float=0):
	if regenerating: return
	regenerating = true
	
	if interval == 0:
		current_health += rate * delta
		regenerating = false
		return
	
	current_health += rate
	regen_timer = 0.0
	regen_interval = interval
	while regen_timer < regen_interval:
		regen_timer += delta
		await get_tree().process_frame
	
	regenerating = false

var is_dead:= false
signal died
signal exploded
signal gameover
signal forever
func die():
	if is_dead: return
	is_dead = true
	emit_signal("died", char_body)
	emit_signal("exploded", char_body)
	
	char_body._visibility(false)
	
	if char_body.base.tag == "player": # Avoid null reference when player died (temporary)
		await get_tree().create_timer(2.0).timeout
		#get_tree().quit()
		emit_signal("gameover")
		await forever
	
	if get_tree() and get_tree() != null: await get_tree().create_timer(10.0).timeout
	
	if char_body.base.tag == "enemy":
		Stat.Enemy.erase(char_body)
		char_body.queue_free()
