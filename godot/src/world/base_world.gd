extends Node
class_name World

const PLAYER_SCENE:PackedScene = preload("res://src/player/player.tscn")

func _ready():
	Globals.tilemap = $PlatformsLayer
	Events.spawn_requested.connect(_on_spawn_requested)

func _on_spawn_requested():
	if not $Player:
		var player = PLAYER_SCENE.instantiate()
		player.position = Globals.last_checkpoint
		add_child(player)
		
