extends Node2D
class_name StaticComponent

var is_solid: bool
var interactable: bool

func _init(set_solid:bool, set_interactable:=false):
	is_solid = set_solid
	interactable = set_interactable
