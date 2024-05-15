@tool
extends Sprite2D
class_name MapGrid

@onready var anim_player: AnimationPlayer = $AnimationPlayer
var placeholder: Placeholder = null
var activated: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Engine.is_editor_hint():
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
	if placeholder and activated:
		material.set_shader_parameter("valid_placement", placeholder.is_valid)

func _input(event):
	if event is InputEventMouseMotion and activated:
		var mouse_pos: Vector2 = get_global_mouse_position()
		print(mouse_pos)
		var viewport_rect: Vector2 = get_viewport_rect().size
		print(viewport_rect)
		var circle_pos: Vector2 = Vector2(mouse_pos.x / viewport_rect.x, mouse_pos.y / viewport_rect.y)
		print(circle_pos)
		material.set_shader_parameter("circle_position", circle_pos)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Appear":
		anim_player.play("PlaceBlockLoop")

func _on_block_requested(event_placeholder: Placeholder) -> void:
	placeholder = event_placeholder
	activate()

func _on_block_played(block) -> void:
	deactivate()
	placeholder = null
