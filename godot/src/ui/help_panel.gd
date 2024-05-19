extends Panel


func _on_resume_game_button_pressed() -> void:
	hide()
	get_tree().paused = false
