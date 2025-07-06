extends Node
class_name BaseComponent

var id: int
var tag: String
@export var is_player: bool = false

func _init(new_tag:="none"):
	id = Stat.id_count
	Stat.id_count += 1
	
	tag = new_tag
