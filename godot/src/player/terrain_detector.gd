extends Area2D

signal terrain_detected()


func _ready():
	body_entered.connect(_on_terrain_detected)
	

func _on_terrain_detected(body: Variant):
	if body is TileMapLayer:
		Logger.debug("Terrain detected!")
	
