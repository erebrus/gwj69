extends Node

@onready var sfx_button: AudioStreamPlayer = $sfx_button


func _on_quit_button_pressed() -> void:
	sfx_button.play()
	await sfx_button.finished
	get_tree().quit()


func _on_start_button_pressed() -> void:
	sfx_button.play()
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($music,"volume_db",-60, 1)
	await tween.finished
	
	Globals.start_game()
