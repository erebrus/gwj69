extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sfx_button: AudioStreamPlayer = $sfx_button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("start")
	await animation_player.animation_finished
	animation_player.play("loop")



func _on_quit_button_pressed() -> void:
	sfx_button.play()
	await sfx_button.finished
	get_tree().quit()


func _on_start_button_pressed() -> void:
	sfx_button.play()
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($music,"volume_db",-60,.5)
	await get_tree().create_timer(1).timeout
	#await sfx_button.finished
	
	Globals.start_game()	
