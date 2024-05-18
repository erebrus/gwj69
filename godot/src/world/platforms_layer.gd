extends TileMapLayer
class_name PlatformsLayer

const VOID_ID := 1

func is_cell_empty(coords:Vector2i) -> bool:
	var cell_id = get_cell_source_id(coords)
	if cell_id != -1 and cell_id != VOID_ID:
		return false
	
	for child in get_children():
		if (child.has_method("is_cell_empty")):
			var child_cell_offset = local_to_map(child.position)
			var child_coords = coords - child_cell_offset
			if child_coords.x < -10 or child_coords.x > 10 or child_coords.y < -10 or child_coords.y > 10:
				continue
			
			if !child.is_cell_empty(child_coords):
				return false
		
	return true
	

func global_cell(point: Vector2) -> Vector2i:
	return local_to_map(to_local(point))
	

func cell_center(point: Vector2) -> Vector2i:
	return map_to_local(local_to_map(point))
	

func cell_top_left(point: Vector2) -> Vector2i:
	return cell_center(point) - tile_set.tile_size / 2
	

func get_state() -> Dictionary:
	var blocks: Array
	for child in get_children():
		if child.has_method("get_state"):
			var state = child.get_state()
			if not state.is_empty():
				blocks.append(state)
	
	return {
		"tilemap": tile_map_data,
		"blocks": blocks,
	}
	

func set_state(state: Dictionary) -> void:
	Globals.tilemap.tile_map_data = state.tilemap 
	for block_state in state.blocks:
		var block = load(block_state.scene).instantiate()
		add_child(block)
		block.set_state(block_state)
	
