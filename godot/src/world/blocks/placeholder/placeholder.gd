extends Node2D


signal valid_changed(valid:bool)
signal placed
signal dismissed


var block: BaseBlock


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
	
	add_child(block)
	block.disable()
	
	for shape in block.get_collision_shapes():
		area.add_child(shape)
	

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
	var block_position = tilemap.to_local(block.global_position)
	block.enable()
	remove_child(block)
	
	block.position = block_position
	get_parent().add_child(block)
	placed.emit()
	
	queue_free()
	

func _destroy() -> void:
	Logger.info("cancel placing block")	
	dismissed.emit()
	queue_free()
	

func _center_on_cell(point: Vector2) -> void:
	var tile = tilemap.local_to_map(tilemap.to_local(point))
	global_position = tilemap.to_global(tilemap.map_to_local(tile) - half_size)
	

