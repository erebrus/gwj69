extends Label

var starting_pos: Vector2 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_pos = global_position
	visible = false
	modulate.a = 0


func _on_card_selection_card_selected(card: CardUI) -> void:
	text = "+1 " + card.card_name.text
	visible = true
	global_position = starting_pos
	var alpha_tween = create_tween()
	alpha_tween.tween_property(self, "modulate:a", 1.0, .5).set_ease(Tween.EASE_IN_OUT).set_delay(2)
	alpha_tween.tween_property(self, "modulate:a", 0.0, .5).set_ease(Tween.EASE_IN_OUT).set_delay(1.5)
	var movement_tween = create_tween()
	movement_tween.tween_property(self, "global_position", starting_pos + Vector2(0.0, 30.0), .5).set_delay(2)
