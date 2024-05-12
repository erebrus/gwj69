extends CustomCardUIData

func _do_play(target = null):
	Logger.info(" Played Long Jump card")
	Events.long_jump_requested.emit()
