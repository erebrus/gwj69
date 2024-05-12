extends "res://src/world/base_world.gd"

const Block = preload("res://src/world/blocks/base_block.tscn")

@onready var tilemap = $PlatformsLayer


func _input(event): 
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_B:
			print("targetting mode")
			var block = Block.instantiate()
			block.global_position = get_viewport().get_mouse_position()
			add_child(block)
			move_child(block, 1)
			
		
	if event is InputEventMouseMotion:
		%MouseCoords.text = str(event.global_position)
		var tile = tilemap.local_to_map(tilemap.to_local(event.global_position))
		%TileCoords.text = str(tile)
