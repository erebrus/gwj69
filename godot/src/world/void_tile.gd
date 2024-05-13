extends Node2D

const SPEED_VARIABILITY := .25
@onready var sprite: AnimatedSprite2D = $Sprite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var frame_count := sprite.sprite_frames.get_frame_count("default")
	
	var speed_delta := randf_range(-SPEED_VARIABILITY, SPEED_VARIABILITY)
	sprite.speed_scale += speed_delta
	sprite.frame = randi() % frame_count
	sprite.play("default")
