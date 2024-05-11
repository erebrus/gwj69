extends CustomCardUIData

func _do_play(target = null):
	Logger.info(" Played Long Jump card")
	Events.request_long_jump.emit()
