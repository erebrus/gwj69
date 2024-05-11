extends Node2D

signal wall_detected()
signal jump_detected(height:float)
signal fall_detected(height:float)


@export var max_jump_distance: int = 50:
	set(value):
		max_jump_distance = value
		%JumpRayCast.position.y = -max_jump_distance
		%JumpRayCast.target_position = Vector2.DOWN * max_jump_distance


var flip:= false:
	set(value):
		if value != flip:
			flip = value
			var ahead = -%WallRayCast.target_position.x
			%WallRayCast.target_position.x = ahead
			%JumpRayCast.position.x = ahead
			%FallRayCast.position.x = ahead
			%WallRayCast.force_raycast_update()
			%JumpRayCast.force_raycast_update()
			%FallRayCast.force_raycast_update()

var wall_ahead:= false:
	set(value):
		if value and not wall_ahead:
			wall_detected.emit()
		wall_ahead = value


var jump_height:= 0:
	set(value):
		if value != jump_height and value > 0:
			jump_detected.emit(value)
		jump_height = value


var fall_height:=0:
	set(value):
		if value != fall_height and value > 0:
			fall_detected.emit(value)
		fall_height = value
	

@onready var wall_raycast: RayCast2D = %WallRayCast
@onready var jump_raycast: RayCast2D = %JumpRayCast
@onready var fall_raycast: RayCast2D = %FallRayCast


func _ready():
	max_jump_distance = max_jump_distance
	

func _physics_process(_delta: float) -> void:
	wall_ahead = wall_raycast.is_colliding()
	
	if wall_ahead:
		var height = global_position.y - jump_raycast.get_collision_point().y
		if height < max_jump_distance:
			jump_height = height
		else:
			jump_height = 0
	#else:
		#if fall_raycast.is_colliding():
			#var height = fall_raycast.get_collision_point().y - global_position.y
			#if height <= 0:
				#fall_height = 0
			#else:
				#fall_height = height
		#else:
			#fall_height = fall_raycast.target_position.y
	


