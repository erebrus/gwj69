class_name TilemapBlock extends BaseBlock

const VOID_ID := 3


@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var half_size = tilemap.tile_set.tile_size / 2

func _process(delta: float) -> void:
	var parent = get_parent()
	if parent is Placeholder:
		tilemap.material.set_shader_parameter("ColorParameter", valid_placement_color if parent.is_valid else invalid_placement_color)

func disable() -> void:
	super.disable()
	$AnimationPlayer.play("Place")
	tilemap.collision_enabled = false
	

func enable() -> void:
	super.enable()
	$AnimationPlayer.play("Create")
	tilemap.collision_enabled = true
	

func get_collision_shapes() -> Array[CollisionPolygon2D]:
	var shapes: Array[CollisionPolygon2D]
	
	for cell in tilemap.get_used_cells():
		var cell_data = tilemap.get_cell_tile_data(cell)
		for layer in 2: # number of layers in tileset (only layer 1 is used for blocks so far)
			for i in cell_data.get_collision_polygons_count(layer):
				var collision_polygon = cell_data.get_collision_polygon_points(layer, i) * collision_shape_transform
				var collision_shape = CollisionPolygon2D.new()
				collision_shape.polygon = collision_polygon
				collision_shape.position = Vector2i((2 * cell.x + 1) * half_size.x, (2 * cell.y + 1) * half_size.y)
				shapes.append(collision_shape)
	
	return shapes
	

func is_cell_empty(coords: Vector2i) -> bool:
	var cell_position = tilemap.map_to_local(coords)
	var rotated_coords = tilemap.local_to_map(cell_position.rotated(-rotation))
	var cell_id = tilemap.get_cell_source_id(rotated_coords)
	return cell_id == -1 or cell_id == VOID_ID
