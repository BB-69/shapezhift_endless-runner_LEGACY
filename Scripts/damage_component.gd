extends Node
class_name DamageComponent
var char_body: CharacterBody2D

@export_group("Attack")
@export var can_attack:= true
@export var base_damage:= 20
enum DamageType {Physical}
@export var damage_type:= DamageType

@export var _crit_chance:= 0
var crit_chance:
	get: return _crit_chance
	set(value): _crit_chance = clamp(value, 0, 100)
@export var crit_multiplier:= 1

@export var cooldown:= 0.3

signal damage_dealt
func deal_damage(target, amount: float=base_damage):
	if target.hp.has_method("apply_damage") and target.hp.is_alive and char_body.hp.is_alive:
		var is_crit:bool = randf() < crit_chance
		var damage:= base_damage * (crit_multiplier if is_crit else 1)
		target.hp.apply_damage(damage)
		emit_signal("damage_dealt", target, damage, is_crit)
		can_attack = false
		await get_tree().create_timer(cooldown).timeout
		can_attack = true





func _ready() -> void:
	if get_parent() is CharacterBody2D: char_body = get_parent()

func _process(delta: float) -> void:
	if !char_body.phy.colliding.is_empty(): for object in char_body.phy.colliding:
		if object is CharacterBody2D and object.base.tag != char_body.base.tag and can_attack and object.hp.is_alive:
			if char_body.base.tag == "enemy": player_damage(object)
			return
			if can_landing_damage: landing_damage(object)
			if can_ram_damage: ram_damage(object)

@export_group("Ability")
@export var can_landing_damage: bool
@export var can_ram_damage: bool

func player_damage(object):
	if object is PlayerClass:
		if can_attack:
			deal_damage(object)

func landing_damage(object):
	if (object.is_on_ceiling() or object.phy.was_on_ceiling) and (char_body.is_on_floor() or object.phy.was_on_floor):
		deal_damage(object)

func ram_damage(object):
	if object.is_on_wall() and char_body.is_on_wall():
		deal_damage(object)
