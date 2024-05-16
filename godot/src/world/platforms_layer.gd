extends TileMapLayer
class_name PlatformsLayer

const VOID_ID := 3
func is_cell_empty(coords:Vector2i)->bool:
	var cell_id = get_cell_source_id(coords)
	return cell_id == -1 or cell_id == VOID_ID
	
