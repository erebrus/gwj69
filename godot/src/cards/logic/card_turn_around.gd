extends CustomCardUIData

func can_play():
	return Globals.player_alive
	

func _do_play():
	Events.turn_around_requested.emit()
