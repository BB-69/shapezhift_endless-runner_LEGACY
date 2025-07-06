extends Node2D
@onready var grid_map: TileMapLayer = $GridMap
@onready var floor_map: TileMapLayer = $FloorMap
@onready var platform_map: TileMapLayer = $PlatformMap

var grid_map_thread:= Thread.new()
var floor_map_thread:= Thread.new()
var platform_map_thread:= Thread.new()

var tile_size: float
var screen_width_tiles: int
var screen_height_tiles: int
var gen_distance_x: int
var gen_distance_y: int
func _ready() -> void:
	tile_size = floor_map.tile_set.tile_size.x
	generated_grid_tile = []
	generated_floor_columns = {}
	generated_groups = []
	screen_width_tiles = int(get_viewport_rect().size.x / tile_size)
	gen_distance_x = screen_width_tiles * 3 + 20
	screen_height_tiles = int(get_viewport_rect().size.y / tile_size)
	gen_distance_y = screen_height_tiles * 3 + 20

func _process(delta):
	# =========================== TILES MAP ===========================
	var player_x = get_viewport().get_camera_2d().global_position.x
	var tile_x = int(player_x / tile_size)
	var player_y= get_viewport().get_camera_2d().global_position.y
	var tile_y = int(player_y / tile_size)
	
	
	# === GRID GENERATION ===
	#if !grid_map_thread.is_alive():
	#	grid_map_thread = Thread.new()
	_generate_grid_tiles(delta, tile_x, tile_y)
	
	
	# === FLOOR GENERATION ===
	_generate_floor_tiles(delta, tile_x, tile_y)
	
	
	# === PLATFORM GROUP GENERATION ===
	_generate_group_tiles(delta, tile_x, tile_y)
	

# Grid Generation
var process_grid_tile_timer:= 10.0
var process_grid_tile_interval:= 1.0
var grid_tiles_per_frame = 50
var pending_generate_tile_coords = {}
var pending_remove_tile_coords = {}
var generated_grid_tile = []

func _generate_grid_tiles(delta, tile_x: int, tile_y: int):
	process_grid_tile_timer += delta
	if process_grid_tile_timer > process_grid_tile_interval:
		process_grid_tile_timer = 0.0
		for x in range(tile_x - (screen_width_tiles+10), tile_x + (screen_width_tiles+10)):
			for y in range(tile_y - (screen_height_tiles+10), tile_y + (screen_height_tiles+10)):
				var pos = Vector2i(x, y)
				if not generated_grid_tile.has(pos):
					pending_generate_tile_coords[pos] = true
		
		for tile in generated_grid_tile:
			if abs(tile[0] - tile_x) > gen_distance_x/2 or abs(tile[1] - tile_y) > gen_distance_x/2:
				pending_remove_tile_coords[tile] = true
	
	if !(pending_generate_tile_coords.is_empty() and pending_remove_tile_coords.is_empty()):
		var i = 0
		while i < grid_tiles_per_frame and !(pending_generate_tile_coords.is_empty() and pending_remove_tile_coords.is_empty()):
			if !pending_generate_tile_coords.is_empty():
				var generate_coord = pending_generate_tile_coords.keys()[0]
				if !generated_grid_tile.has(generate_coord):
					var pos = Vector2i(generate_coord[0], generate_coord[1])
					_set_grid_tile(pos, Vector2i(0, 0))
					i += 1
				pending_generate_tile_coords.erase(generate_coord)
			
			if !pending_remove_tile_coords.is_empty():
				var remove_coord = pending_remove_tile_coords.keys()[0]
				if generated_grid_tile.has(remove_coord):
					var pos = Vector2i(remove_coord[0], remove_coord[1])
					_set_grid_tile(pos)
					i += 1
				pending_remove_tile_coords.erase(remove_coord)

func _set_grid_tile(pos, atlas=null):
	if atlas != null:
		grid_map.set_cell(pos, 0, atlas, 0)
		generated_grid_tile.append(pos)
	else:
		grid_map.set_cell(pos, -1)
		generated_grid_tile.erase(pos)


# Floor Generation
var generated_floor_columns = {}
func _generate_floor_tiles(delta, tile_x: int, tile_y: int):
	for i in range(tile_x - gen_distance_x, tile_x + gen_distance_x):
		if not generated_floor_columns.has(i):
			_generate_floor_column(i)
	
	var floor_to_remove = []
	for x_tile in generated_floor_columns.keys():
		if abs(x_tile - tile_x) > gen_distance_x:
			var row = 0
			while floor_map.get_cell_source_id(Vector2i(x_tile, row)) != -1:
				floor_map.set_cell(Vector2i(x_tile, row), -1)
				row += 1
			floor_to_remove.append(x_tile)
	for x in floor_to_remove:
		generated_floor_columns.erase(x)

func _generate_floor_column(x_tile):
	_set_floor_tile(x_tile, Vector2i(1, 0), 0)
	_set_floor_tile(x_tile, Vector2i(1, 1), 1, 4)
	generated_floor_columns[x_tile] = true

func _set_floor_tile(x_tile, atlas: Vector2i, row_start: int, row_end: int = 0):
	if row_end != 0:
		for y in range(row_start, row_end):
			floor_map.set_cell(Vector2i(x_tile, y), 0, atlas, 0)
	else:
		floor_map.set_cell(Vector2i(x_tile, row_start), 0, atlas, 0)

# Group Generation
var generated_groups = []
var min_distance := 8
var width = 2
var height = 2

func _generate_group_tiles(delta, tile_x: int, tile_y: int):
	if randi() % 4 == 0:
		var group_x = tile_x + randi_range(-gen_distance_x, gen_distance_x)
		var group_y = -randi_range(4, 20)
		var group_pos = Vector2i(group_x, group_y)
		if not _is_group_generated(group_pos):
			_generate_block_group(group_x, group_y)
	
	var group_to_remove = []
	for group in generated_groups:
		var group_pos = group["pos"]
		var group_size = group["size"]
		if abs(group_pos.x - tile_x) > gen_distance_x:
			for x in range(group_size.x):
				for y in range(group_size.y):
					var tile_pos = group_pos + Vector2i(x, y)
					platform_map.set_cell(tile_pos, -1)
			group_to_remove.append(group)
	for g in group_to_remove:
		generated_groups.erase(g)

func _generate_block_group(x_start, y_start):
	if y_start >= 9:
		height = randi_range(3, 4)
		width = randi_range(3, 8)
	else:
		height = 2
		width = randi_range(2, 5)
	
	if _is_platform_too_close(x_start, y_start, width, height): return
	
	for x in range(width):
		for y in range(height):
			var tile_x = x_start + x
			var tile_y = y_start + y
			var atlas = _get_atlas_tile(x, y, width, height)
			platform_map.set_cell(Vector2i(tile_x, tile_y), 0, atlas, 0)
	# Store this platform’s origin + size for future cleanup & distance check
	generated_groups.append({
		"pos": Vector2i(x_start, y_start),
		"size": Vector2i(width, height)
	})

func _is_group_generated(pos: Vector2i) -> bool:
	return pos in generated_groups

func _get_atlas_tile(x, y, w, h) -> Vector2i:
	var tile = Vector2i()

	if y == 0:
		# Top row
		if x == 0:
			tile = Vector2i(0, 0) # top-left
		elif x == w - 1:
			tile = Vector2i(2, 0) # top-right
		else:
			tile = Vector2i(1, 0) # top-edge
	elif y == h - 1:
		# Bottom row
		if x == 0:
			tile = Vector2i(0, 2) # bottom-left
		elif x == w - 1:
			tile = Vector2i(2, 2) # bottom-right
		else:
			tile = Vector2i(1, 2) # bottom-edge
	else:
		# Middle row
		if x == 0:
			tile = Vector2i(0, 1) # left edge
		elif x == w - 1:
			tile = Vector2i(2, 1) # right edge
		else:
			tile = Vector2i(1, 1) # center

	return tile

func _is_platform_too_close(x_start, y_start, width = 3, height = 3) -> bool:
	# Check with player position
	if Stat.player_pos_tile != null:
		if Stat.player_pos_tile.distance_to(Vector2i(x_start, y_start)) < gen_distance_x/2:
			return true
	else: push_error("Stat.player_pos_tile hasn't been initialized.")
	
	# Check with existing groups
	for group in generated_groups:
		var group_pos = group["pos"]
		var group_size = group["size"]

		var group_end = group_pos + group_size
		var this_end = Vector2i(x_start + width, y_start + height)

		var overlap_x = !(x_start + width + min_distance < group_pos.x or x_start > group_end.x + min_distance)
		var overlap_y = !(y_start + height < group_pos.y or y_start > group_end.y)

		if overlap_x and overlap_y:
			return true # Too close or overlapping
	return false
