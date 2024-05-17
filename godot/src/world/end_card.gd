extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("default")



func _on_body_entered(body: Node2D) -> void:
	Logger.info("End Level Card Collected.")
	sprite.play("gather")
	$sfx_gather.play()
	Events.end_card_collected.emit()
	await get_tree().create_timer(1.4).timeout
	
