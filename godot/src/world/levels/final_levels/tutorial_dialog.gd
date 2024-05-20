extends Control
class_name TutorialDialog

@export var text: String
@onready var label: RichTextLabel = $Control/MarginContainer/Label
@onready var skip_button: Button = $Button
var can_skip = true
signal skip_requested()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0.0
	label.visible_ratio = 0.0
	visible = false


func show_text() -> void:
	skip_button.disabled = !can_skip
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, .5).set_delay(.5)
	tween.tween_property(label, "visible_ratio", 1.0, 2.0)

func hide_text() -> void:
	var tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, .5)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)


func _on_button_pressed() -> void:
	skip_requested.emit()
	
func _process(delta: float) -> void:
	if visible:
		skip_button.disabled = !can_skip
