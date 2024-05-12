extends CustomCardUIData

func _do_play():
	Events.long_jump_requested.emit()
