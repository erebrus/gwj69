extends Node
class_name World


@onready var platforms_layer: PlatformsLayer = $PlatformsLayer


var checkpoint: CheckPoint


func _ready():
	Globals.tilemap = $PlatformsLayer
	Events.player_respawned.connect(_on_player_respawned)
	
	await get_tree().process_frame
	_on_player_respawned($Player)
	

func place_checkpoint(value: CheckPoint):
	if checkpoint != null:
		checkpoint.queue_free()
	
	checkpoint = value
	
	$PlatformsLayer.add_child(checkpoint)
	

func _on_player_respawned(player):
	var rt = RemoteTransform2D.new()
	player.add_child(rt)
	rt.remote_path="/root/Game/BaseWorld/Camera" #HACK unique name doesn't work
	

