extends Node2D

var char_body: CharacterBody2D

# Debug
var debug_position
var debug_position_text: String

var debug_timer
var debug_timer_text: String
var current_time:= 0.0

func _ready() -> void:
	# CharacterBody2D of parent node of THIS node
	if get_parent(): char_body = get_parent()
	
	debug_position = get_child(0)
	debug_timer = get_child(1)

func _process(delta: float) -> void:
	debug_update_position()
	debug_update_time(delta)
	
	if char_body.base.tag == "player" and !char_body.hp.is_alive: debug_end()

func debug_update_position():
	var pos: Vector2i = char_body.global_position/128
	debug_position_text = "(" + str(pos.x) + ", " + str(-pos.y) + ")"
	debug_position.text = debug_position_text
	Stat.player_pos_tile = pos

func debug_update_time(delta):
	current_time += delta
	if current_time < 60.0:
		debug_timer_text = ("%.2f" % current_time) + "s"
		debug_timer.text = debug_timer_text
	elif current_time < 3600.0:
		var total_min:int = int(current_time / 60.0)
		var min:String = ("%s" % total_min) + "m"
		var sec:String = ("%s" % int(current_time - total_min*60.0)) + "s"
		debug_timer_text = min + "" + sec
		debug_timer.text = debug_timer_text
	else:
		var total_hour:int = int(current_time / 3600.0)
		var total_min:int = int(current_time - total_hour*60.0)
		var hour:String = ("%s" % total_hour) + "h"
		var min:String = ("%s" % total_min) + "m"
		var sec:String = ("%s" % int(current_time - total_min*60.0)) + "s"
		debug_timer_text = hour + "" + min + "" + sec
		debug_timer.text = debug_timer_text

var sent_debug_end:= false
func debug_end():
	if sent_debug_end: return
	sent_debug_end = true
	
	print("Last tile position: '%s'" % debug_position_text)
	print("Total time survived: '%s'" % debug_timer_text)
