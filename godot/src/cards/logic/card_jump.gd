extends CustomCardUIData

func _do_play():
	Events.jump_requested.emit()
