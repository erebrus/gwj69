extends CustomCardUIData
class_name CardBlock
const Block:PackedScene = preload("res://src/world/blocks/block.tscn")
 
func _get_block():
	return Block.instantiate()

func _do_play(target = null):
	Logger.info(" Played %s" % nice_name)
	Events.request_block_at.emit(_get_block(), target)
