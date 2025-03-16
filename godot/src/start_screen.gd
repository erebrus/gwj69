extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sfx_button: AudioStreamPlayer = $sfx_button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.in_game = false
	Globals.music_manager.fade_in_menu_music()
	
	animation_player.play("start")
	await animation_player.animation_finished
	animation_player.play("loop")
	

func _exit_tree() -> void:
	Globals.music_manager.fade_menu_music()
	

func _on_quit_button_pressed() -> void:
	sfx_button.play()
	await sfx_button.finished
	get_tree().quit()


func _on_start_button_pressed() -> void:
	sfx_button.play()
	#await sfx_button.finished	
	await get_tree().create_timer(.75).timeout
	Globals.start_game()
