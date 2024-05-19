extends Panel

@onready var sfx_button: AudioStreamPlayer = $sfx_button


func _process(delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_cancel"):
		close()
		return
		
func _on_restart_level_button_pressed() -> void:
	sfx_button.play()
	await sfx_button.finished 
	Events.restart_requested.emit()
	Events.close_menu_requested.emit()

func _on_resume_game_button_pressed() -> void:
	sfx_button.play()
	await sfx_button.finished 
	close()

func close():
	Events.close_menu_requested.emit()

func _on_quit_button_pressed() -> void:
	sfx_button.play()
	Globals.fade_music(Globals.game_music)
	await sfx_button.finished 
	Events.close_menu_requested.emit()
	get_tree().change_scene_to_file("res://src/start_screen.tscn")
