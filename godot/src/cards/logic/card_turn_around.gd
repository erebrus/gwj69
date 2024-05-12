extends CustomCardUIData

func _do_play(target = null):
	Logger.info(" Played Turn around card")
	Events.turn_around_requested.emit()
