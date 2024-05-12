extends Node2D


signal valid_changed(valid:bool)


@export var block_scene: PackedScene
var block: BaseBlock

var collision_shape_transform = Transform2D(0, Vector2(0.9,0.9), 0, Vector2.ZERO)

var is_valid:=true:
	set(value):
		if value != is_valid:
			is_valid = value
			valid_changed.emit(is_valid)
		


@onready var tilemap = Globals.tilemap
@onready var half_size = Vector2(tilemap.tile_set.tile_size/2)
@onready var area = $Area2D


func _ready() -> void:
	_center_on_cell(global_position)
	
	block = block_scene.instantiate()
	block.collision_enabled = false
	add_child(block)
	
	_calculate_collision_shape()
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_center_on_cell(event.global_position)
	
	if event.is_action_pressed("left_click"):
		_place()
		
	if event.is_action_pressed("right_click"):
		_destroy()
	

func _physics_process(_delta:float) -> void:
	is_valid = area.get_overlapping_bodies().is_empty() and area.get_overlapping_areas().is_empty()
	

func _place() -> void:
	if not is_valid:
		# todo: play invalid placement ui sound
		return
	
	Logger.info("block placed")
	var block_position = block.global_position
	block.collision_enabled = true
	remove_child(block)
	
	block.global_position = block_position
	get_parent().add_child(block)
	
	queue_free()
	

func _destroy() -> void:
	Logger.info("cancel placing block")	
	queue_free()
	

func _center_on_cell(point: Vector2) -> void:
	var tile = tilemap.local_to_map(tilemap.to_local(point))
	global_position = tilemap.to_global(tilemap.map_to_local(tile)) - half_size
	

func _calculate_collision_shape() -> void:
	for cell in block.get_used_cells():
		var cell_data = block.get_cell_tile_data(cell)
		for layer in 2: # number of layers in tileset (only layer 1 is used for blocks so far)
			for i in cell_data.get_collision_polygons_count(layer):
				var collision_polygon = cell_data.get_collision_polygon_points(layer, i) * collision_shape_transform
				var collision_shape = CollisionPolygon2D.new()
				collision_shape.polygon = collision_polygon
				collision_shape.position = Vector2i((2 * cell.x + 1) * half_size.x, (2 * cell.y + 1) * half_size.y)
				area.add_child(collision_shape)
