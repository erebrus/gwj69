extends "res://src/world/base_world.gd"


func _ready():
	await get_tree().create_timer(6).timeout
	print("..................................................................")
	print("changing height")
	$Player.jump_height = 100
	$Player.jump_velocity = -500

func _input(event):
	if event is InputEventMouseMotion:
		$MouseCoords.text = str(event.global_position)
