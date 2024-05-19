extends TilemapBlock

const START_ATLAS_COORDS = Vector2i(0, 0)
const END_ATLAS_COORS = Vector2i(2,0)

@export var speed := 50.0


@onready var slider_layer: TileMapLayer = $SliderLayer
@onready var player_detector_rotation: Node2D = %RotationPoint
@onready var player_detector: Area2D = %RotationPoint/PlayerDetection

var player: Player
var start: float
var end: float


func _ready() -> void:
	player_detector.body_entered.connect(_on_player_entered)
	
	var start_coords = slider_layer.get_used_cells_by_id(-1, START_ATLAS_COORDS).front()
	var end_coords = slider_layer.get_used_cells_by_id(-1, END_ATLAS_COORS).front()
	start = slider_layer.map_to_local(start_coords).x
	end = slider_layer.map_to_local(end_coords).x
	

func _exit_tree() -> void:
	if player != null:
		player.release()
	

func _physics_process(delta: float) -> void:
	if player == null:
		return
		
	var movement = speed * delta
	
	if start < end:
		# go forward
		tilemap.position.x = min(end - start + 1, tilemap.position.x + movement)
		if tilemap.position.x >= end - start + 1:
			_reach_end()
	
	if start > end:
		# go backwards
		tilemap.position.x = max(0, tilemap.position.x - movement)
		if tilemap.position.x <= 0:
			_reach_end()
	

func disable() -> void:
	super.disable()
	slider_layer.collision_enabled = false
	

func enable() -> void:
	super.enable()
	slider_layer.collision_enabled = true
	

func place(at: Vector2, angle: float) -> void:
	super.place(at, angle)
	player_detector_rotation.rotation = -angle
	

func clear_blocks_at(coords: Vector2i) -> void:
	if slider_layer.get_cell_source_id(_get_rotated_coords(coords)) != -1:
		queue_free()
	

func is_cell_empty(coords: Vector2i) -> bool:
	var block_offset = tilemap.local_to_map(tilemap.position)
	var rotated_coords = _get_rotated_coords(coords) - block_offset
	var cell_id = tilemap.get_cell_source_id(rotated_coords)
	return cell_id == -1 or cell_id == VOID_ID
	

func _reach_end() -> void:
	player.release()
	player = null
	var tmp = end
	end = start
	start = tmp
	

func _on_player_entered(body) -> void:
	if not body is Player or not Globals.player_alive:
		return
	
	player = body
	player.capture(player_detector)
	
	
