extends Panel

@onready var sfx_button: AudioStreamPlayer = $sfx_button


func _on_restart_level_button_pressed() -> void:
	sfx_button.play()
	await sfx_button.finished 
	Events.restart_requested.emit()
	Events.close_menu_requested.emit()

func _on_resume_game_button_pressed() -> void:
	sfx_button.play()
	await sfx_button.finished 
	Events.close_menu_requested.emit()

func _on_quit_button_pressed() -> void:
	sfx_button.play()
	await sfx_button.finished 
	get_tree().quit()
