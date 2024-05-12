class_name BaseBlock extends Node2D


signal valid_changed(valid:bool)

var is_valid:=true:
	set(value):
		if value != is_valid:
			is_valid = value
			valid_changed.emit(is_valid)
		

var is_placed:= false


@onready var blocks = $TileMapLayer
@onready var tilemap = Globals.tilemap
@onready var half_size = Vector2(tilemap.tile_set.tile_size/2)


func _input(event: InputEvent):
	if is_placed:
		return
	
	if event is InputEventMouseMotion:
		var tile = tilemap.local_to_map(tilemap.to_local(event.global_position))
		global_position = tilemap.to_global(tilemap.map_to_local(tile)) - half_size
	
	if event.is_action_pressed("left_click"):
		_place()
		
	if event.is_action_pressed("right_click"):
		_destroy()
	

func _place() -> void:
	is_placed = true
	

func _destroy() -> void:
	if is_placed:
		# todo: destroy animation
		pass
	
	queue_free()
	

