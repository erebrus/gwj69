class_name TerrainDetectionDebug extends Node2D

@export var enabled:= true:
	set(value):
		if value == enabled:
			return
		
		enabled = value
		if enabled and is_inside_tree():
			generate_rects()
			current_cell = get_current_cell()
	

@export var start_cell: Vector2i = Vector2i(0,0)
@export var end_cell: Vector2i = Vector2i(100, 100)
@export var cell_size: Vector2 = Vector2(8,8)
@export var dot_size: Vector2 = Vector2(2,2)

var rects: Dictionary
var current_cell: Vector2i:
	set(value):
		if value == current_cell:
			return
		current_cell = value
		if enabled:
			update()


func _ready() -> void:
	Events.block_placed.connect(_on_block_placed)
	if enabled:
		generate_rects()
		await get_tree().process_frame
		current_cell = get_current_cell()
	

func generate_rects() -> void:
	var offset = cell_size / 2 - dot_size / 2
	for x in range(start_cell.x, end_cell.y):
		for y in range(start_cell.y, end_cell.y):
			var cell = Vector2i(x,y)
			var rect = ColorRect.new()
			rect.position = Vector2(cell) * cell_size + offset
			rect.size = dot_size
			add_child(rect)
			rects[cell] = rect
	update.call_deferred()
	

func update() -> void:
	Logger.debug("updating cell status")
	var tilemap = Globals.tilemap
	for cell in rects:
		if tilemap.is_cell_empty(cell + current_cell):
			rects[cell].color = Color.RED
		else:
			rects[cell].color = Color.GREEN
	

func get_current_cell() -> Vector2i:
	return Globals.tilemap.global_cell(global_position)
	

func _on_block_placed(_block: BaseBlock) -> void:
	if enabled:
		update()
	
