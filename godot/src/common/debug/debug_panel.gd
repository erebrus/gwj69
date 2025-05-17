extends PanelContainer


func _ready() -> void:
	for music in Types.GameMusic:
		%MusicTension.add_item(music, Types.GameMusic[music])
	
	for i in Globals.levels.size():
		var level = Globals.levels[i]
		var level_name = level.resource_path.get_file().replace(".tscn", "")
		%LevelSelection.add_item(level_name, i)
	
	hide()
	 

func _input(event: InputEvent) -> void:
	if Debug.debug_build and event.is_action_pressed("debug"):
		if visible:
			hide()
		else:
			open()
	

func open() -> void:
	if not is_instance_valid(Globals.game):
		return
	
	%TickOnCardDrawn.button_pressed = Globals.game.void_card_tick
	%TickOnTimer.button_pressed = Globals.game.void_time_tick
	
	%CardSelection.clear()
	for card in Globals.game.card_engine.card_database:
		%CardSelection.add_item(card.nice_name)
	
	%VoidCooldown.text = "%0.4f" % Globals.game.start_void_cooldown
	%VoidCooldownProgression.text = "%0.4f" % Globals.game.void_cooldown_progression
	%VoidVerticalSpeedProgression.text = "%0.4f" % Globals.game.vertical_progression_factor
	show()
	

func _on_music_tension_item_selected(index:int):
	Globals.music_manager.change_game_music_to(index)
	

func _on_restart_pressed():
	if !Globals.in_game:
		await Globals.start_game()
		await get_tree().create_timer(0.1).timeout
	Globals.current_level_idx =  %LevelSelection.get_selected_id()
	Globals.game.reload_level()
	

func _on_next_level_pressed():
	Events.level_ended.emit()
	

func _on_game_over_pressed():
	if Globals.in_game:
		Events.player_died.emit()
	

func _on_win_game_pressed():
	Globals.win_game()
	

func _on_void_cooldown_text_changed(new_text: String):
	if not new_text.is_valid_float():
		return
	Globals.game.start_void_cooldown = new_text.to_float()
	Globals.game.reset_void_cooldown()
	

func _on_tick_on_timer_toggled(toggled_on: bool):
	Globals.game.void_time_tick = toggled_on
	

func _on_tick_on_card_drawn_toggled(toggled_on: bool):
	Globals.game.void_card_tick = toggled_on
	

func _on_void_cooldown_progression_text_changed(new_text: String):
	if not new_text.is_valid_float():
		return
	Globals.game.void_cooldown_progression = new_text.to_float()
	

func _on_reset_void_cooldown_pressed():
	Globals.game.reset_void_cooldown()
	

func _on_add_card_pressed():
	var card = %CardSelection.get_item_text(%CardSelection.selected)
	Globals.game.card_engine.create_card_in_pile(card, CardPileUI.Piles.hand_pile)
	


func _on_vertical_speed_progression_text_changed(new_text: String) -> void:
	if not new_text.is_valid_float():
		return
	Globals.game.vertical_progression_factor = new_text.to_float()
