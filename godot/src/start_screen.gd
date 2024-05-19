extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sfx_button: AudioStreamPlayer = $sfx_button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.play_music(Globals.menu_music)
	await animation_player.animation_finished
	animation_player.play("loop")



func _on_quit_button_pressed() -> void:
	sfx_button.play()
	await sfx_button.finished
	get_tree().quit()


func _on_start_button_pressed() -> void:
	sfx_button.play()
	Globals.fade_music(Globals.menu_music,.5)
	await sfx_button.finished	
	Globals.start_game()	
