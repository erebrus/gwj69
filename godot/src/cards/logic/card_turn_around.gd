extends CustomCardUIData

func _do_play():
	Events.turn_around_requested.emit()
