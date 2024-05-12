extends "res://src/world/base_world.gd"


@onready var tilemap = $PlatformsLayer


func _input(event):
	if event is InputEventMouseMotion:
		%MouseCoords.text = str(event.global_position)
		var tile = tilemap.local_to_map(tilemap.to_local(event.global_position))
		%TileCoords.text = str(tile)
