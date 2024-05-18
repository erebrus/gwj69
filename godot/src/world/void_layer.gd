class_name VoidLayer extends TileMapLayer

signal void_expanded(cell: Vector2i)

const SIDES: Array[TileSet.CellNeighbor] = [
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,
]

const VOID_ID:= 1
const TTL=3
var border_cells: Array[Vector2i]

var cell_counters = {}

func _ready() -> void:
	Events.tick.connect(_on_tick)
	for cell in get_used_cells():
		if _has_empty_sides(cell):
			border_cells.append(cell)
			cell_counters[cell]=TTL
		
	

func get_state() -> Dictionary:
	return {
		"tilemap": tile_map_data,
	}
	

func set_state(state: Dictionary) -> void:
	tile_map_data = state.tilemap 
	

func expand(target: Vector2) -> void:
	var target_coord:= local_to_map(target)
	
	Logger.info("The Void creeps toward %s -> %s" % [
		target, 
		target_coord
	])
	
	var new_border: Array[Vector2i]
	for cell in border_cells:
		new_border.append_array(_grow(cell, target_coord))
	
	border_cells = new_border
	

func _grow(cell: Vector2i, target: Vector2i) -> Array[Vector2i]:
	var new_border: Array[Vector2i]
	
	var n = get_neighbor_cell(cell, _cell_to_target_side(cell, target))
	if cell_is_empty(n):
		new_border.append_array(_spawn_void(n))
	
	if _has_empty_sides(cell):
		new_border.append(cell)
	
	return new_border
	

func _spawn_void(cell: Vector2i) ->  Array[Vector2i]:
	var new_border:  Array[Vector2i]
	
	cell_counters[cell]=TTL
	
	set_cell(cell, VOID_ID, Vector2i.ZERO, 0)
	void_expanded.emit(cell)
	
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
	

func _cell_to_target_side(cell: Vector2i, target: Vector2i) -> TileSet.CellNeighbor:
	var angle = Vector2(target - cell).angle()
	var quadrant = roundi(angle / (PI / 2))
	
	match (quadrant):
		0: return TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE
		1: return TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE
		2: return TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE
		-2: return TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE
		-1: return TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE
	
	return  TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE
	
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
	if (Globals.player_alive):
		expand(Globals.player.position)
		fade()
		
	
