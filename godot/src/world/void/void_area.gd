@tool
class_name VoidArea extends Area2D

@export var size:Vector2 = Vector2(400,300):
	set(_v):
		size=_v
		_update_shape()
@export var map_rect:Rect2

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var active:bool = false

func _ready() -> void:
	_update_shape()
	
	
func is_active()->bool:
	return active
	
func _update_shape() -> void:
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = self.size
	$CollisionShape2D.shape = rect_shape
	


func _on_body_entered(body: Node2D) -> void:
	active = true
	Logger.info("Area at %s is active" % map_rect.position)


func _on_body_exited(body: Node2D) -> void:
	active = false
	Logger.info("Area at %s is no longer active" % map_rect.position)
