class_name BaseBlock extends Node2D


var collision_shape_transform =  Transform2D(0, Vector2(0.9,0.9), 0, Vector2.ZERO)
var enabled = true


@export var timed = true
@export var ttl = 3
@export var valid_placement_color: Color
@export var invalid_placement_color: Color

func _ready() -> void:
	if timed:
		Events.tick.connect(_on_tick)
	

func disable() -> void:
	enabled = false
	if Events.tick.is_connected(_on_tick):
		Events.tick.disconnect(_on_tick)
	

func enable() -> void:
	enabled = true
	if timed:
		Events.tick.connect(_on_tick)
	

func get_collision_shapes() -> Array[CollisionPolygon2D]:
	return []
	

func _destroy_tile():
	queue_free()
	

func _on_tick():
	ttl -= 1
	if ttl == 0:
		_destroy_tile()
	

