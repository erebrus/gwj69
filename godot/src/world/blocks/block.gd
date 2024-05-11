extends StaticBody2D

@export var ttl=3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.tick.connect(_on_tick)


func _on_tick():
	ttl -= 1
	if ttl == 0:
		_destroy_tile()
		
func _destroy_tile():
	queue_free()
	
