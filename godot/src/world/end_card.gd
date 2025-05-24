extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vfx: AnimatedSprite2D = $Vfx

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("default")
	Events.end_card_highlight.connect(show_vfx)
	await get_tree().process_frame
	show_vfx(4.0)
	Events.request_camera.emit(global_position, 2.0)
	
func show_vfx(duration:float):
	vfx.visible=true
	vfx.play("default")
	await get_tree().create_timer(duration).timeout
	vfx.stop()
	vfx.visible = false
	
func _on_body_entered(_body: Node2D) -> void:
	Logger.info("End Level Card Collected.")
	sprite.play("gather")
	$sfx_gather.play()
	Events.end_card_collected.emit()
	await get_tree().create_timer(1.4).timeout
	
