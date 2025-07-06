extends Node

# === Object ===
var id_count: int = 0

# === Game ===
var Camera
var ScreenSize:= Vector2.ZERO
var CameraCover: CameraCanvas

# === Manager ===
var Aud: AudioManager
var Ptc: ParticleManager

# === Player ===
var Player: CharacterBody2D
var player_pos_tile: Vector2i
var Enemy:= []
var enemy_pos_tile:= []

func _init() -> void:
	pass

func _process(delta: float) -> void:
	if Player: player_pos_tile = Player.position/128
	for index in Enemy.size():
		while enemy_pos_tile.size() < Enemy.size():
			enemy_pos_tile.append(Vector2i.ZERO)
		enemy_pos_tile[index] = Enemy[index].position/128

func is_offscreen(obj) -> bool:
	if !Camera: return false
	if abs(obj.global_position.x - Camera.global_position.x) > ScreenSize.x + 256:
		return true
	if abs(obj.global_position.y - Camera.global_position.y) > ScreenSize.y + 256:
		return true
	return false





# =============== Game State ===============
enum GameState {Idle, Ongoing, Gameover}
const game_scene = preload("res://Scenes/game.tscn")

func _on_gameover():
	reset()
	get_tree().reload_current_scene()

func reset():
	id_count = 0
	
	Camera = null
	ScreenSize = Vector2.ZERO
	
	Aud.queue_free()
	Ptc.queue_free()
	
	Player.queue_free()
	player_pos_tile = Vector2i.ZERO
	Enemy.clear()
	enemy_pos_tile.clear()
