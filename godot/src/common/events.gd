extends Node

signal request_position()

signal discard_requested()

signal jump_requested()
signal long_jump_requested()
signal turn_around_requested()

signal request_block_at(block, position:Vector2i)

signal tick()
