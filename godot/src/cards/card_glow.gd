@tool
extends TextureRect

var position_delta: Vector2
var previous_pos: Vector2
var clicked = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_alpha(0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position_delta = global_position - previous_pos
	previous_pos = global_position
	material.set_shader_parameter("position_delta", position_delta)


func _on_custom_card_ui_card_hovered(_card: CardUI) -> void:
	create_tween().tween_method(set_alpha, .3, 1.0, .30)


func _on_custom_card_ui_card_unhovered(_card: CardUI) -> void:
	if !clicked:
		var ending_alpha = 0.0
		create_tween().tween_method(set_alpha, material.get_shader_parameter("alpha_f"), ending_alpha, .40).set_ease(Tween.EASE_OUT)
	
func set_emission(value: float):
	material.set_shader_parameter("emission_f", value)

func set_alpha(value: float):
	material.set_shader_parameter("alpha_f", value)

func _on_custom_card_ui_card_played(_card: CardUI) -> void:
	create_tween().tween_method(set_alpha, material.get_shader_parameter("alpha_f"), 0.0, .75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_custom_card_ui_card_shuffled_to_draw(_card: CardUI) -> void:
	create_tween().tween_method(set_alpha, material.get_shader_parameter("alpha_f"), 0.0, .40).set_ease(Tween.EASE_IN)


func _on_custom_card_ui_card_drawn(_card: CardUI) -> void:
	create_tween().tween_method(set_alpha, material.get_shader_parameter("alpha_f"), .3, .40).set_ease(Tween.EASE_IN)


func _on_custom_card_ui_card_dropped(_card: CardUI) -> void:
	clicked = false
	create_tween().tween_method(set_alpha, material.get_shader_parameter("alpha_f"), 0.0, .2).set_ease(Tween.EASE_OUT)


func _on_custom_card_ui_card_clicked(_card: CardUI) -> void:
	clicked = true
	create_tween().tween_method(set_alpha, material.get_shader_parameter("alpha_f"), 1.0, .30)
