extends CustomCardUIData

func _do_play():
	Events.level_ended.emit()
	Logger.info ("emitted")
	

