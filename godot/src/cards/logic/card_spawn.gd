extends CustomCardUIData

func _do_play():
	Events.spawn_requested.emit()
