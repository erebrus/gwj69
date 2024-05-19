extends CustomCardUIData

func can_play():
	return Globals.player_alive
	

func _do_play():
	pass
	#Events.long_jump_requested.emit()
