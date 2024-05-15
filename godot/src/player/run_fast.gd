extends GPUParticles2D

var flipped_texture: Texture2D
var normal_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	normal_texture = texture
	var img = texture.get_image()
	img.flip_x()
	flipped_texture = ImageTexture.create_from_image(img)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().velocity.x < 0:
		texture = flipped_texture
	else:
		texture = normal_texture
