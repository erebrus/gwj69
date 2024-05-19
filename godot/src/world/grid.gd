@tool
extends Sprite2D
class_name MapGrid

@onready var anim_player: AnimationPlayer = $AnimationPlayer
var placeholder: Placeholder = null
var activated: bool = false

@export var platform_layer: PlatformsLayer
@export var camera: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Engine.is_editor_hint():
		Events.game_mode_changed.connect(_on_game_mode_changed)
		Events.block_requested.connect(_on_block_requested)
		Events.block_placed.connect(_on_block_played)

func activate() -> void:
	anim_player.play("Appear")
	activated = true

func deactivate() -> void:
	anim_player.play("Disappear")
	activated = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if placeholder and activated:
		material.set_shader_parameter("valid_placement", placeholder.is_valid)
	if !activated and platform_layer:
		global_position = camera.global_position - Vector2(fmod(camera.global_position.x, 16.0), fmod(camera.global_position.y, 16.0) - 8.0)

func _input(event):
	if event is InputEventMouseMotion and activated:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var offset = (mouse_pos - global_position) / 2.0
		var viewport_rect: Vector2 = get_viewport_rect().size
		var circle_pos: Vector2 = Vector2(.5, .5) + Vector2((offset.x) / viewport_rect.x, (offset.y) / viewport_rect.y)
		material.set_shader_parameter("circle_position", circle_pos)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Appear":
		anim_player.play("PlaceBlockLoop")
		
		
func _on_game_mode_changed(mode: Types.GameMode) -> void:
	if mode == Types.GameMode.ChoosingCard:
		deactivate()
	elif mode == Types.GameMode.PlacingBlock:
		activate()
	
func _on_block_requested(event_placeholder: Placeholder) -> void:
	placeholder = event_placeholder
	#activate()

func _on_block_played(block) -> void:
	placeholder = null
