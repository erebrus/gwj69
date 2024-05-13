@tool
extends TextureRect

var position_delta: Vector2
var previous_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position_delta = global_position - previous_pos
	previous_pos = global_position
	material.set_shader_parameter("position_delta", position_delta)
	#print(position_delta)


func _on_custom_card_ui_card_hovered(card: CardUI) -> void:
	create_tween().tween_method(set_emission, material.get_shader_parameter("emission_f"), 76.0, .25)


func _on_custom_card_ui_card_unhovered(card: CardUI) -> void:
	create_tween().tween_method(set_emission, material.get_shader_parameter("emission_f"), 10.0, .25).set_ease(Tween.EASE_IN_OUT)

func set_emission(value: float):
	material.set_shader_parameter("emission_f", value)
