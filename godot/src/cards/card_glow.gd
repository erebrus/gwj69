@tool
extends TextureRect

var position_delta: Vector2
var previous_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_alpha(0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position_delta = global_position - previous_pos
	previous_pos = global_position
	material.set_shader_parameter("position_delta", position_delta)
	#print(position_delta)


func _on_custom_card_ui_card_hovered(card: CardUI) -> void:
	create_tween().tween_method(set_alpha, .3, 1.0, .30)


func _on_custom_card_ui_card_unhovered(card: CardUI) -> void:
	var ending_alpha = .30 if card.in_hand() else 0.0
	create_tween().tween_method(set_alpha, material.get_shader_parameter("alpha_f"), ending_alpha, .40).set_ease(Tween.EASE_OUT)

func set_emission(value: float):
	material.set_shader_parameter("emission_f", value)

func set_alpha(value: float):
	material.set_shader_parameter("alpha_f", value)

func _on_custom_card_ui_card_played(card: CardUI) -> void:
	create_tween().tween_method(set_alpha, material.get_shader_parameter("alpha_f"), 0.0, .75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_custom_card_ui_card_shuffled_to_draw(card: CardUI) -> void:
	create_tween().tween_method(set_alpha, material.get_shader_parameter("alpha_f"), 0.0, .40).set_ease(Tween.EASE_IN)


func _on_custom_card_ui_card_drawn(card: CardUI) -> void:
	create_tween().tween_method(set_alpha, material.get_shader_parameter("alpha_f"), .3, .40).set_ease(Tween.EASE_IN)
