class_name VoidLayer extends TileMapLayer



const SIDES: Array[TileSet.CellNeighbor] = [
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,
]

const VOID_ID:= 1
const TTL=3
const SPAWN_MOD = 2

var current_spawn = 1
var cell_counters = {}

func _ready() -> void:
	Events.tick.connect(_on_tick)
	for cell in get_used_cells():
		Events.new_void_cell.emit(cell)
		cell_counters[cell]=TTL
		
	

func get_state() -> Dictionary:
	return {
		"tilemap": tile_map_data,
		"cell_counters": cell_counters
	}
	

func set_state(state: Dictionary) -> void:
	tile_map_data = state.tilemap 
	cell_counters = state.cell_counters
	

func expand(target: Vector2) -> void:
	var target_coord:= local_to_map(target)
	
	Logger.info("The Void creeps toward %s -> %s" % [
		target, 
		target_coord
	])
	
	for cell in cell_counters.keys():
		_grow(cell, target_coord)
	

func _grow(cell: Vector2i, target: Vector2i) -> void:
	for side in _cell_to_target_sides(cell, target):
		var n = get_neighbor_cell(cell, side)
		if cell_is_empty(n):
			_spawn_void(n, n-cell)
		
	

func _should_spawn(cell: Vector2i, direction: Vector2i) -> bool:
	if direction.x != 0 and cell.y % SPAWN_MOD != current_spawn:
		return false
	if direction.y != 0 and cell.x % SPAWN_MOD != current_spawn:
		return false
	return true
	

func _spawn_void(cell: Vector2i, direction: Vector2i) ->  Array[Vector2i]:
	var new_border:  Array[Vector2i]
	
	if not _should_spawn(cell, direction):
		return new_border
	
	cell_counters[cell]=TTL
	
	set_cell(cell, VOID_ID, Vector2i.ZERO, 0)
	Events.new_void_cell.emit(cell)
	
	if _has_empty_sides(cell):
		new_border.append(cell)
	
	return new_border
	

func _has_empty_sides(cell: Vector2i) -> bool:
	for side in SIDES:
		var n = get_neighbor_cell(cell, side)
		if cell_is_empty(n):
			return true
	return false
	

func cell_is_empty(cell: Vector2i) -> bool:
	return get_cell_source_id(cell) == -1
	

func _cell_to_target_sides(cell: Vector2i, target: Vector2i) -> Array[TileSet.CellNeighbor]:
	var sides: Array[TileSet.CellNeighbor]
	
	if cell.x != target.x:
		if cell.x < target.x:
			sides.append(TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE)
		else:
			sides.append(TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE)
		
	
	if cell.y != target.y:
		if cell.y < target.y:
			sides.append(TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE)
		else:
			sides.append(TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE)
		
	return sides
	

func fade():
	var to_remove=[]
	for cell in cell_counters.keys():
		if cell_counters[cell]<1:
			to_remove.append(cell)
		else:
			cell_counters[cell] = cell_counters[cell] - 1
			
	for cell in to_remove:
		set_cell(cell,-1)
		cell_counters.erase(cell)
	

func _on_tick() -> void:
	current_spawn = (current_spawn + 1) % SPAWN_MOD
	var target: Vector2 = get_parent().get_void_target()
	expand(target)
	fade()
	Events.global_void_expanded.emit()
		
	
