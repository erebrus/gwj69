extends Node

signal game_mode_changed(mode: Types.GameMode)
signal card_error()

signal card_destroy_requested(card:CardUI)
signal discard_requested()

signal spawn_requested()
signal jump_requested()
#signal long_jump_requested() #TODO implement or remove
signal turn_around_requested()
signal speed_requested(factor:float, duration:float)
signal block_requested(placeholder: Placeholder)
signal block_placed(block)


signal player_died()
signal player_respawned(player)

signal checkpoint_requested()

signal end_card_collected()
signal tick()
signal level_ended()
signal game_ended()
