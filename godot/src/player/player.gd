extends CharacterBody2D


@export var base_speed := 100.0
@export var jump_velocity := -100.0

func _ready():
	velocity.x = base_speed

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()
	
	
