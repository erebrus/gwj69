class_name VoidLayer extends TileMapLayer


@export var void_area_path:NodePath
const SIDES: Array[TileSet.CellNeighbor] = [
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,
]

const VOID_ID:= 1
const VOID_TERRAIN:=1
const SPAWN_MOD = 2

var current_spawn = 1
var cell_counters = {}
var void_areas:Array[VoidArea] = []

func _ready() -> void:

		
	Events.tick.connect(_on_tick)
	for cell in get_used_cells():
		Events.new_void_cell.emit(cell)
		cell_counters[cell]=VoidData.new(cell)
		
	await get_tree().process_frame
	

	for area in get_areas():
		void_areas.append(area)
		var nw_corner_pos = to_local(area.global_position) - area.size/2
		var se_corner_pos = to_local(area.global_position) + area.size/2
		var area_cell_pos = local_to_map(nw_corner_pos)
		var area_size = Vector2(
			round(se_corner_pos.x-nw_corner_pos.x)/tile_set.tile_size.x,
			round(se_corner_pos.y-nw_corner_pos.y)/tile_set.tile_size.y,
			)
		area.map_rect=Rect2(area_cell_pos,area_size)
		Logger.info("Added Void Area pos:%s size:%s" % [area.map_rect.position, area.map_rect.size])

	for cell in cell_counters.keys():
		assign_area_to_void(cell_counters[cell])
			

func assign_area_to_void(vd: VoidData):
	if not vd.area:
		for area in get_areas():
			Logger.trace("Looking for %s in %s-%s" % [vd.cell, area.map_rect.position, area.map_rect.size])
			if area.map_rect.has_point(vd.cell):
				vd.area = area
				break
		if not vd.area:
			Logger.warn("No area found for void at %s" % vd.cell)

func get_areas():
	return get_node(void_area_path).get_children()
	
func get_state() -> Dictionary:
	return {
		"tilemap": tile_map_data,
		"cell_counters": cell_counters.duplicate() #TODO check if needs deep
	}
	

func set_state(state: Dictionary) -> void:
	tile_map_data = state.tilemap 
	cell_counters = state.cell_counters.duplicate() #TODO check if needs deep
	

func expand(target: Vector2) -> void:
	var target_coord:= local_to_map(target)
	
	Logger.info("The Void creeps toward %s -> %s" % [
		target, 
		target_coord
	])
	
	for cell in cell_counters.keys():
		if cell_counters[cell].is_active():
			cell_counters[cell].expanded_this_tick=false
			_grow(cell, target_coord)
	

func _grow(cell: Vector2i, target: Vector2i) -> void:
	for side in _cell_to_target_sides(cell, target):
		var n = get_neighbor_cell(cell, side)
		var vertical :bool = n.y != cell.y
		if cell_is_empty(n):
			if vertical and  randf()>Globals.game.vertical_progression_factor:
				Logger.debug("Skipped vertical progression at %s" % n)
			else:
				_spawn_void(n, n-cell)
				cell_counters[cell].expanded_this_tick=true
		
	

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
	
	cell_counters[cell]=VoidData.new(cell)
	assign_area_to_void(cell_counters[cell])
	
	set_cells_terrain_connect([cell], 0, VOID_TERRAIN)
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
		if cell_counters[cell].is_expired():
			to_remove.append(cell)
		else:
			if cell_counters[cell].expanded_this_tick:
				cell_counters[cell].tick()
			
	for cell in to_remove:
		set_cell(cell,-1)
		cell_counters.erase(cell)
	

func _on_tick() -> void:
	if not Globals.player_alive:
		Logger.debug("Player not alive. Void not progressing.")
		return
	current_spawn = (current_spawn + 1) % SPAWN_MOD
	var target: Vector2 = get_parent().get_void_target()
	expand(target)
	fade()
	Events.global_void_expanded.emit()
		

func count_void_in_area(pos:Vector2i, size:int)->int:
	var count:=0
	for x in range(pos.x-size, pos.x+size+1):
		for y in range(pos.y-size, pos.y+size+1):
			if not cell_is_empty(Vector2i(x,y)):
				count += 1
	return count
