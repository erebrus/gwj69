extends Node2D


@export var start_cell: Vector2i = Vector2i(0,0)
@export var end_cell: Vector2i = Vector2i(100, 100)


var rects: Dictionary

func _ready():
	var tilemap = Globals.tilemap
	for x in range(start_cell.x, end_cell.y):
		for y in range(start_cell.y, end_cell.y):
			var cell = Vector2i(x,y)
			var rect = ColorRect.new()
			rect.position = tilemap.map_to_local(cell)
			rect.size = Vector2(2,2)
			add_child(rect)
			rects[cell] = rect
	Events.block_placed.connect(_on_block_placed)
	_on_block_placed.call_deferred(null)
	

func _on_block_placed(_block) -> void:
	Logger.info("updating cell status")
	var tilemap = Globals.tilemap
	for cell in rects:
		if tilemap.is_cell_empty(cell):
			rects[cell].color = Color.RED
		else:
			rects[cell].color = Color.GREEN
