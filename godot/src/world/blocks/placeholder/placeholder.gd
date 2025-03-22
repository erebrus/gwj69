extends Node2D
class_name Placeholder

signal valid_changed(valid:bool)
signal position_selected
signal placed
signal dismissed


var block: BaseBlock


@onready var build_block_sfx: AudioStreamPlayer2D = $sfx/build_block
@onready var build_group_block_sfx: AudioStreamPlayer2D = $sfx/build_group_block
@onready var error_sfx: AudioStreamPlayer2D = $sfx/error

var is_valid:=true:
	set(value):
		if value != is_valid:
			is_valid = value
			valid_changed.emit(is_valid)
		


@onready var tilemap = Globals.tilemap
@onready var half_size = Vector2(tilemap.tile_set.tile_size/2)
@onready var area = $Area2D


func _ready() -> void:
	Events.player_died.connect(_destroy)
	
	_center_on_cell(global_position)
	
	add_child(block)
	block.disable()
	
	for shape in block.get_collision_shapes():
		area.add_child(shape)
	
	Events.card_clicked.connect(_destroy)
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_center_on_cell(get_global_mouse_position())
	
	if event.is_action_pressed("left_click"):
		_place()
		
	if event.is_action_pressed("right_click"):
		_destroy()
		
	if event.is_action_pressed("rotate_cw"):
		rotation += PI/2
		
	if event.is_action_pressed("rotate_ccw"):
		rotation -= PI/2

func _physics_process(_delta:float) -> void:
	is_valid = area.get_overlapping_bodies().is_empty() and area.get_overlapping_areas().is_empty()

func _place() -> void:
	if not is_valid:
		error_sfx.play()
		return
	
	position_selected.emit()
	Logger.info("block placed")
	var block_position = tilemap.to_local(block.global_position)
	if len(tilemap.get_used_cells()) > 1:
		build_block_sfx.play()
	else:
		build_group_block_sfx.play()
	block.enable()
	remove_child(block)
	
	block.place(block_position, rotation)
	get_parent().add_child(block)
	placed.emit()
	Events.block_placed.emit(block)
	

func _destroy() -> void:
	Logger.info("cancel placing block")	
	dismissed.emit()
	queue_free()
	

func _center_on_cell(point: Vector2) -> void:
	var tile = tilemap.local_to_map(tilemap.to_local(point))
	global_position = tilemap.to_global(tilemap.map_to_local(tile) - half_size)
	
	
func _on_build_block_finished() -> void:
	queue_free()

func _on_build_group_block_finished() -> void:
	queue_free()
