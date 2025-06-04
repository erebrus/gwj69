extends Control

@onready var sfx_button: AudioStreamPlayer = $sfx_button
@onready var bg: TextureRect = $BG


@export var bg_textures:Array[Texture]
var anim_idx=0

func _ready() -> void:
	Globals.in_game = false
	Globals.music_manager.fade_in_menu_music()
	


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


func _on_animation_timer_timeout() -> void:
	anim_idx = wrapi(anim_idx + 1, 0, bg_textures.size())
	bg.texture=bg_textures[anim_idx]
