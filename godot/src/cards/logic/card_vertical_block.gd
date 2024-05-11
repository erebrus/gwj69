extends CardBlock

const VerticalBlock:PackedScene = preload("res://src/world/blocks/horizontal_block.tscn")
func _get_block():
	return VerticalBlock.instantiate()
