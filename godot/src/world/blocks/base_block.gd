class_name BaseBlock extends Node2D


var collision_shape_transform =  Transform2D(0, Vector2(0.9,0.9), 0, Vector2.ZERO)


func disable() -> void:
	pass
	

func enable() -> void:
	pass
	

func get_collision_shapes() -> Array[CollisionPolygon2D]:
	return []

