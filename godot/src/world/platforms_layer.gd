extends TileMapLayer
class_name PlatformsLayer

const VOID_ID := 3
func is_cell_empty(coords:Vector2i) -> bool:
	var cell_id = get_cell_source_id(coords)
	if cell_id != -1 and cell_id != VOID_ID:
		return false
	
	for child in get_children():
		if (child.has_method("is_cell_empty")):
			var child_cell_offset = local_to_map(child.position)
			if !child.is_cell_empty(coords - child_cell_offset):
				return false
		
	return true
	
