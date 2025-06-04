extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vfx_anchor: Node2D = $VfxAnchor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("default")
	Events.end_card_highlight.connect(show_vfx)
	await get_tree().process_frame
	show_vfx(4.0)
	Events.request_camera.emit(global_position, 2.0)
	
func show_vfx(duration:float):
	if vfx_anchor.get_child_count() == 0:
		return
	vfx_anchor.visible=true
	for vfx in vfx_anchor.get_children():
		vfx.play("default")
	await get_tree().create_timer(duration).timeout
	await (vfx_anchor.get_child(0) as AnimatedSprite2D).animation_finished
	for vfx in vfx_anchor.get_children():
		vfx.stop()
	vfx_anchor.visible = false
	
func _on_body_entered(_body: Node2D) -> void:
	Logger.info("End Level Card Collected.")
	sprite.play("gather")
	$sfx_gather.play()
	Events.end_card_collected.emit()
	await get_tree().create_timer(1.4).timeout
	
