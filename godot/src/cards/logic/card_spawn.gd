extends CustomCardUIData

func _do_play():
	Events.spawn_requested.emit()
	
#func can_play()->bool:
	#return not Globals.player_alive
