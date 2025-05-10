extends Control

@export var card_scene: PackedScene


@onready var card_engine: CardPileUI = $CardEngine
@onready var card_container: Container = $CardContainer


func _ready() -> void:
	for json_data in card_engine.card_database:
		
		var card_ui = card_scene.instantiate()
		card_ui.frontface_texture = json_data.texture_path
		card_ui.backface_texture = json_data.backface_texture_path
		
		card_ui.card_data = ResourceLoader.load(json_data.resource_script_path).new()
		for key in json_data.keys():
			if key != "texture_path" and key != "backface_texture_path" and key != "resource_script_path":
				card_ui.card_data[key] = json_data[key]
		
		var stylebox = StyleBoxEmpty.new()
		stylebox.set_content_margin_all(5)
		var border = PanelContainer.new()
		border.add_theme_stylebox_override("panel", stylebox)
		border.add_child(card_ui)
		
		card_container.add_child(border)
