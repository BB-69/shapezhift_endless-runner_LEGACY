extends Node
class_name AIComponent

# Simulated Actions
var move_left	:= false
var move_right	:= false
var move_up		:= false
var move_down	:= false
func get_action(action:String):
	match action:
		"move_left"	: return move_left
		"move_right": return move_right
		"move_up"	: return move_up
		"move_down"	: return move_down
		_: return false
func get_action_just(action:String):
	match action:
		"move_left"	: return just_move_left
		"move_right": return just_move_right
		"move_up"	: return just_move_up
		"move_down"	: return just_move_down
		_: return false

var moved_left	:= false
var moved_right	:= false
var moved_up	:= false
var moved_down	:= false
var just_move_left	:= false
var just_move_right	:= false
var just_move_up	:= false
var just_move_down	:= false
func update_action() -> void:
	just_move_left = !moved_left and move_left
	moved_left = move_left
	just_move_right = !moved_right and move_right
	moved_right = move_right
	just_move_up = !moved_up and move_up
	moved_up = move_up
	just_move_down = !moved_down and move_down
	moved_down = move_down
