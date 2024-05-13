extends Node

signal game_mode_changed(mode: Types.GameMode)


signal discard_requested()

signal jump_requested()
#signal long_jump_requested() #TODO implement or remove
signal turn_around_requested()
signal speed_requested(factor:float, duration:float)

signal tick()
