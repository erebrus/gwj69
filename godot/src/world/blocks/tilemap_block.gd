class_name TilemapBlock extends BaseBlock

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var half_size = tilemap.tile_set.tile_size / 2


func disable() -> void:
	super.disable()
	tilemap.collision_enabled = false
	

func enable() -> void:
	super.enable()
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
