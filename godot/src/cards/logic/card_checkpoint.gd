extends CustomCardUIData
class_name CardCheckPoint


func can_play() -> bool:
	return Globals.player_alive

func play():
	if can_play():
		Logger.info("Played %s card" % nice_name)
		played.emit()
		Events.checkpoint_requested.emit()
		
	else:
		Logger.info("Can't play %s card" % nice_name)
		Events.card_error.emit()
	

