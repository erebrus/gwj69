extends Control


@export_file("*.json") var json_card_database_path : String
@export var card_ui_scene: PackedScene


var card_database := [] # an array of JSON `Card` data


@onready var card_control: Control = %CardContainer


func _ready():
	load_json_path()
	for data in card_database:
		var card = create_card(data)
		

func load_json_path():
	card_database = _load_json_cards_from_path(json_card_database_path)
	

func _load_json_cards_from_path(path : String):
	var found = []
	if path:
		var json_as_text = FileAccess.get_file_as_string(path)
		var json_as_dict = JSON.parse_string(json_as_text)
		if json_as_dict:
			for c in json_as_dict:
				found.push_back(c)
	return found


func create_card(json_data):
	var card_ui: CustomCardUI = card_ui_scene.instantiate()
	card_ui.frontface_texture = json_data.texture_path
	card_ui.backface_texture = json_data.backface_texture_path
	
	card_ui.card_data = ResourceLoader.load(json_data.resource_script_path).new()
	for key in json_data.keys():
		if key != "texture_path" and key != "backface_texture_path" and key != "resource_script_path":
			card_ui.card_data[key] = json_data[key]

	var margin = MarginContainer.new()
	margin.custom_minimum_size = Vector2(168,224)
	margin.add_child(card_ui)
	card_control.add_child(margin)
	return card_ui
	
