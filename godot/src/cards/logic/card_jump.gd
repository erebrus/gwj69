extends CustomCardUIData

func _do_play(target = null):
	Logger.info(" Played Jump card")
	Events.request_jump.emit()
