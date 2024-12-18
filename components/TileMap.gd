# @Ref: https://www.youtube.com/watch?v=ztPbGyQnKPo
extends TileMap

@onready
var player: CharacterBody2D = get_parent().get_child(1)

# ===== Exports
# ============================================================================ #

@export
var CHUNK_SIZE: int = 4
@export
var CHUNKS_AROUND_PLAYER: int = 1
@export
var tileLayer: int = 0 # From the TileMap screen dropdown (Layer #)
@export
var terrainSet: int = 0 # Terrain set with Mode Dropdown
@export
var terrainIdx: int = 0 # Specific terrain under the set with a color picker

const procedural_map: bool = true

# ===== Class Parameters
# ============================================================================ #

var tile_size: Vector2i = tile_set.tile_size;
var loaded_chunks: Dictionary = {}
#var mapNoise: FastNoiseLite = FastNoiseLite.new()
var draw_chunk_thread: Thread = null

# ===== Lifecycle hooks
# ============================================================================ #

# Called when the node enters the scene tree for the first time.
func _ready():
	if(procedural_map):
		#print('_ready', tile_size)
		#mapNoise.seed = randi()
		_clear_chunks()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(procedural_map):
		var player_position: Vector2 = player.position
		_manage_chunks(player_position)
		#_call_fn_threaded(_manage_chunks.bind(player_position))

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	if(draw_chunk_thread != null):
		draw_chunk_thread.wait_to_finish()

# ===== Class Functions
# ============================================================================ #

## https://github.com/godotengine/godot/issues/71388
## https://github.com/godotengine/godot/issues/75317
func _call_fn_threaded(fn: Callable):
	if(draw_chunk_thread != null && !draw_chunk_thread.is_alive()):
		#print('Task Completed')
		draw_chunk_thread = null
		force_update(0)

	if(draw_chunk_thread != null):
		#print('Task still running!')
		return;
	draw_chunk_thread = Thread.new()
	draw_chunk_thread.start(fn)

# Pixels - (pos)
# 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
# Tiltes (2 pixel size) - (tileMapsPos)
# 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5
# Chunks (2 tile size) - (chunkPos)
# 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2
# var playr_pos: Vector2 = player.position
# var mouse_pos: Vector2 = get_local_mouse_position()
# var tile_pos: Vector2i = local_to_map(mousePos)
# var chnk_pos: Vector2i = local_to_map(tile_pos)
# var chnk_pos: Vector2i = _map_to_chunk(tile_pos)

## Same as local_to_map but for chunks, can use local_to_map is CHUNK_SIZE is same as tile_size
func map_to_chunk(tile_pos: Vector2) -> Vector2i:
	return Vector2i(floor(tile_pos.x / CHUNK_SIZE), floor(tile_pos.y / CHUNK_SIZE))
	#return tile_pos / CHUNK_SIZE
	# return ((tile_pos / CHUNK_SIZE) + Vector2i(CHUNK_SIZE, CHUNK_SIZE))/2
## Same as map_to_local but for chunks, can use map_to_local is CHUNK_SIZE is same as tile_size
func chunk_to_map(chunk_pos: Vector2i) -> Vector2i:
	return (chunk_pos * CHUNK_SIZE) + (Vector2i(CHUNK_SIZE,CHUNK_SIZE)/2)

## Loads and unloads chunks based on given position
func _manage_chunks(pos: Vector2):
	var tile_map_pos: Vector2i = local_to_map(pos)
	var chunk_pos: Vector2i = map_to_chunk(tile_map_pos)
	#_unload_distant_chunks(chunk_pos, CHUNKS_AROUND_PLAYER)
	_load_chunks_in_radius(chunk_pos, CHUNKS_AROUND_PLAYER)

func _clear_chunks():
	clear()
	loaded_chunks = {}
# ===== Chunk Loading Functions ===== #

## Find neighbor chunks (with radius = ?)
## If chunks arnt generated (in loaded_chunks) the draw them
func _load_chunks_in_radius(chunk_pos: Vector2i, radius: int):
	var region: Array = range(-radius, radius + 1 )
	for x in region:
		for y in region:
			var check_chunk: Vector2i = chunk_pos + Vector2i(x, y)
			if not loaded_chunks.has(check_chunk):
				#_call_fn_threaded(_draw_chunk.bind(check_chunk))
				_draw_chunk(check_chunk)
				loaded_chunks[check_chunk] = true
				print('Load chunk: ', check_chunk)

func _draw_chunk(chunk_pos: Vector2i):
	var tile_map_pos: Vector2i = chunk_to_map(chunk_pos)
	_draw_tile_terrain(tile_map_pos, CHUNK_SIZE, CHUNK_SIZE)

## Adds terrain tiles in a box area
## TODO: Add support for w/h of odd # to round up, from 1=>0 to 1=>2 or 3=>4 instead of 3=>2
func _draw_tile_terrain(tileMapPos: Vector2i, width: int, height: int):
	var region: Vector2i = Vector2i(width,height)
	var startCornerPoint: Vector2i = tileMapPos - (region / 2)
	var endCornerPoint: Vector2i = tileMapPos + (region / 2)

	#print(tileMapPos, region, region / 2, startCornerPoint)

	var groundTerrain: Array[Vector2i] = []

	for x in range(startCornerPoint.x, endCornerPoint.x ):
		for y in range(startCornerPoint.y, endCornerPoint.y):
			var cell: Vector2i = Vector2i(x, y)
			groundTerrain.append((cell))
	set_cells_terrain_connect(0, groundTerrain,0,0, false)

# ===== Chunk Un-loading Functions ===== #

func _unload_distant_chunks(chunk_pos: Vector2i, radius: int):
	for chunk_coord in loaded_chunks.keys():
		if Vector2(chunk_coord).distance_squared_to(chunk_pos) > radius ** 2:
			_remove_chunk(chunk_coord)
			loaded_chunks.erase(chunk_pos)
			print('Un-load chunk: ', chunk_pos)

func _remove_chunk(chunk_pos: Vector2i):
	var tile_map_pos_chunk_center: Vector2 = chunk_to_map(chunk_pos)
	_remove_tiles_from_coordinate(tile_map_pos_chunk_center, CHUNK_SIZE, CHUNK_SIZE)

func _remove_tiles_from_coordinate(coordinate: Vector2, w: int, h: int):
	#print('remove_tiles_from_coordinate', coordinate, w, h)
	for x in range(w):
		for y in range(h):
			var tile_x = coordinate.x - w/2 + x
			var tile_y = coordinate.y - h/2 + y
			erase_cell(0, Vector2i(coordinate.x + tile_x, coordinate.y + tile_y))
