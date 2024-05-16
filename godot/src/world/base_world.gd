extends Node
class_name World

const PLAYER_SCENE:PackedScene = preload("res://src/player/player.tscn")
@onready var platforms_layer: PlatformsLayer = $PlatformsLayer


var checkpoint: CheckPoint


func _ready():
	Globals.tilemap = $PlatformsLayer
	Events.spawn_requested.connect(_on_spawn_requested)
	Events.player_respawned.connect(_on_player_respawned)
	
	await get_tree().process_frame
	_on_player_respawned($Player)
	

func place_checkpoint(value: CheckPoint):
	if checkpoint != null:
		checkpoint.queue_free()
	
	checkpoint = value
	
	checkpoint.position = $PlatformsLayer.map_to_local($PlatformsLayer.local_to_map($Player.position)) - Vector2(4,4)
	$PlatformsLayer.add_child(checkpoint)
	

func _on_spawn_requested():
	if not $Player:
		var player = PLAYER_SCENE.instantiate()
		player.position = Globals.last_checkpoint
		player.tilemap = platforms_layer
		add_child(player)


func _on_player_respawned(player):
	var rt = RemoteTransform2D.new()
	player.add_child(rt)
	rt.remote_path="/root/Game/BaseWorld/Camera" #HACK unique name doesn't work
	

