extends CustomCardUIData

func can_play():
	return Globals.player_alive
	

func _do_play():
	Events.jump_requested.emit()
