extends CustomCardUIData
class_name CardBlock

const PlaceholderScene = preload("res://src/world/blocks/placeholder/placeholder.tscn")


@export var block_scene_path: String:
	set(value):
		if value != block_scene_path:
			block_scene_path = value
			block_scene = load(block_scene_path)

var block_scene: PackedScene


func _get_block():
	return block_scene.instantiate()

func play():
	Globals.game_mode = Types.GameMode.PlacingBlock
	
	var placeholder = PlaceholderScene.instantiate()
	placeholder.block = _get_block()
	placeholder.position_selected.connect(_on_position_selected)
	placeholder.placed.connect(_on_block_placed)
	placeholder.dismissed.connect(_on_card_dismissed)
	
	Globals.tilemap.add_child(placeholder)
	Events.block_requested.emit(placeholder)
	

func _on_position_selected() -> void:
	Logger.info("Played %s card" % nice_name)
	played.emit()
	_do_play()
	

func _on_block_placed() -> void:
	Globals.game_mode = Types.GameMode.ChoosingCard
	

func _on_card_dismissed() -> void:
	Globals.game_mode = Types.GameMode.ChoosingCard
