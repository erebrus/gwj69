extends CardBlock

const HorizontalBlock:PackedScene = preload("res://src/world/blocks/horizontal_block.tscn")

func _get_block():
	return HorizontalBlock.instantiate()
