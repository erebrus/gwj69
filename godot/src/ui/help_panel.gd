extends Panel

func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_cancel"):
		close()
		
func _on_resume_game_button_pressed() -> void:
	$sfx_button.play()
	close()

func close():
	hide()
	get_tree().paused = false
