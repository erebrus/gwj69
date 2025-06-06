extends Node
class_name World

@export var can_skip:bool = false
@export var level_name:String = "" 
@onready var platforms_layer: PlatformsLayer = $PlatformsLayer
@onready var voids_layer: VoidLayer = $VoidLayer

var camera_rt:RemoteTransform2D
var checkpoint: CheckPoint
@onready var camera: MapCamera2D = $Camera


func _ready():
	Logger.info("Loading level %s" % level_name)
	Globals.tilemap = $PlatformsLayer
	Globals.void_tilemap = $VoidLayer
	Events.player_respawned.connect(_on_player_respawned)
	Events.camera_toggled.connect(_on_camera_toggled)
	Events.new_void_cell.connect(_on_new_void_cell)
	Events.request_camera.connect(_on_camera_requested)
	$Camera.position = $StartPosition.position
	

func _on_camera_requested(target_position:Vector2, duration:float):
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Camera, "global_position",target_position,2.0)
	tween.tween_interval(duration)
	tween.tween_property($Camera, "global_position",checkpoint.global_position if checkpoint else $StartPosition.global_position,2.0)
	
		

func get_state() -> Dictionary:
	return {
		"platforms" = platforms_layer.get_state(),
		"voids" = voids_layer.get_state(),
		"player" = $Player.get_state()
	}
	

func set_state(state: Dictionary) -> void:
	platforms_layer.set_state(state.platforms)
	voids_layer.set_state(state.voids)
	camera.position = state.player.position
	
	

func place_checkpoint(value: CheckPoint):
	if checkpoint != null:
		checkpoint.queue_free()
	
	checkpoint = value
	
	platforms_layer.add_child(checkpoint)
	

func _on_player_respawned(player):
	camera_rt = player.get_rt()
	player.set_rt_target("/root/Game/BaseWorld/Camera") #HACK unique name doesn't work
	
	

func _on_camera_toggled(mode:Types.CameraMode):
	camera.drag = mode == Types.CameraMode.FREE
	camera.pan_keyboard = mode == Types.CameraMode.FREE
	camera_rt.update_position = mode != Types.CameraMode.FREE
	
		
func _on_new_void_cell(coords:Vector2i):
	platforms_layer.clear_blocks_at(coords)

func get_start_position()->Vector2:
	return $StartPosition.position

func get_void_target():
	if Globals.player and Globals.player_alive:
		return Globals.player.global_position
	if checkpoint != null:
		return checkpoint.global_position
	else:
		return get_start_position()
	
