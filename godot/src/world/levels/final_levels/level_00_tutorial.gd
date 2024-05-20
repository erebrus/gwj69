extends World

@export var tutorial_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if !Globals.showed_tutorial:
		Globals.showed_tutorial = true
		var tutorial = tutorial_scene.instantiate()
		get_tree().root.add_child(tutorial)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
