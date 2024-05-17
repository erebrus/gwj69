extends CustomCardUIData

func _do_play():
	Events.game_ended.emit()
	

