extends PanelContainer


func _ready() -> void:
	for music in Types.GameMusic:
		%MusicTension.add_item(music, Types.GameMusic[music])
	
	hide()
	 

func _input(event: InputEvent) -> void:
	if Debug.debug_build and event.is_action_pressed("debug"):
		if visible:
			hide()
		else:
			open()
	

func open() -> void:
	# TODO: before show logic
	show()
	

func _on_music_tension_item_selected(index:int):
	Globals.music_manager.change_game_music_to(index)
	

func _on_game_over_pressed():
	print("game over")
	# TODO: Globals.do_lose()
	

func _on_win_game_pressed():
	print("you won")
	# TODO: Globals.do_win()
	
