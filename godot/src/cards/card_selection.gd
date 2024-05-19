extends MarginContainer
class_name SelectionUI

@export_file("*.json") var json_card_database_path : String

@onready var card_control: Control = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/MarginContainer/CardContainer
@onready var choose_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/ButtonMargins/Button
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var pick_card_sfx: AudioStreamPlayer2D  = $sfx/PickCard
@onready var confirm_sfx: AudioStreamPlayer2D = $sfx/Confirm
@onready var card_draw_sfx: AudioStreamPlayer2D = $sfx/CardDraw

@export var cards: Array[CustomCardUI]
@export var total_options = 3
@export var select_amount = 1
@export var card_ui_scene: PackedScene

var initial_starting_pos: Vector2 = Vector2(1280.0/2.0, 760.0/2.0)
var x_offset = 200.0

var card_database := [] # an array of JSON `Card` data
var excluded_cards := ["end_game", "end_level", "The abyss will gaze back into you"]
var selected_card: CardUI

var hiding_cards = false

signal card_selected(card: CardUI)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func show_card_selection() -> void:
	visible = true
	choose_button.disabled = true
	load_json_path()
	create_cards(total_options)
	anim_player.play("Show")
	
func hide_card_selection() -> void:
	anim_player.play("Hide")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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

func is_excluded_card(json_data):
	return json_data.nice_name in excluded_cards

func create_cards(total: int)->void:
	var total_cards = len(card_database)
	var picked_numbers = []
	for i in range(total):
		var random_card_i = randi_range(0, total_cards - 1)
		while random_card_i in picked_numbers or is_excluded_card(card_database[random_card_i]):
			random_card_i = randi_range(0, total_cards - 1)
		picked_numbers.append(random_card_i)
		create_card(card_database[random_card_i])

func create_card(json_data):
	var card_ui = card_ui_scene.instantiate()
	card_ui.frontface_texture = json_data.texture_path
	card_ui.backface_texture = json_data.backface_texture_path
	card_ui.return_speed = 0.125
	card_ui.hover_distance = 20.0
	card_ui.drag_when_clicked = false
	
	card_ui.card_data = ResourceLoader.load(json_data.resource_script_path).new()
	for key in json_data.keys():
		if key != "texture_path" and key != "backface_texture_path" and key != "resource_script_path":
			card_ui.card_data[key] = json_data[key]

	#card_ui.connect("card_hovered", func(c_ui): emit_signal("card_hovered", c_ui))
	#card_ui.connect("card_unhovered", func(c_ui): emit_signal("card_unhovered", c_ui))
	card_ui.connect("card_clicked", _on_card_selected)
	card_ui.connect("card_dropped", _on_card_dropped)
	var target_pos: Vector2 = Vector2(1280/2 - 275 + card_control.get_child_count() * x_offset, 0.0)
	#card_ui.target_position.x = 1280/2 - 275 + card_control.get_child_count() * x_offset
	card_ui.create_tween().tween_property(card_ui, "target_position",target_pos, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_delay(4)
	card_ui.can_do_selection = false
	card_control.add_child(card_ui)
	return card_ui
	
func _on_card_selected(card: CardUI):
	pick_card_sfx.play()
	if card.is_clicked:
		selected_card = card
		choose_button.disabled = false
		var children = card_control.get_children()
		for child in children:
			if child != card and child.is_clicked:
				child.card_dropped.emit(child)
				child.is_clicked = false
				child.target_position.y += child.hover_distance
	#else:
		#selected_card = null
		#choose_button.disabled = true

func _on_card_dropped(card: CardUI):
	pick_card_sfx.play()
	if card == selected_card:
		selected_card = null
		choose_button.disabled = true

func _on_button_pressed() -> void:
	confirm_sfx.play()
	var card_name = selected_card.card_data.nice_name
	if card_name in Globals.current_deck:
		Globals.current_deck[card_name] += 1
	else:
		Globals.current_deck[card_name] = 1
	var children = card_control.get_children()
	for child in children:
		if child != selected_card:
			child.can_do_selection = false
			child.emit_signal("card_dropped", child)
			child.create_tween().tween_property(child, "modulate:a", 0.0, .5 ).set_ease(Tween.EASE_OUT)
		else:
			child.can_do_selection = false
			var target_pos = Vector2(1280 / 2 - 75, -50)
			var pos_tween = child.create_tween()
			pos_tween.tween_property(child, "target_position",target_pos, .5 ).set_ease(Tween.EASE_OUT)
			pos_tween.tween_property(child, "target_position",Vector2(target_pos.x, target_pos.y + 200), .5 ).set_ease(Tween.EASE_OUT).set_delay(.85)
			child.create_tween().tween_property(child, "modulate:a", 0.0, .25 ).set_ease(Tween.EASE_OUT).set_delay(1.25)
	anim_player.play("Hide2")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Hide2" or anim_name == "Hide":
		var children = card_control.get_children()
		card_selected.emit(selected_card)
		for child in children:
			child.queue_free()
		visible = false
	elif anim_name == "Show":
		var children = card_control.get_children()
		for child in children:
			child.can_do_selection = true

func _disable_selected_card():
	if selected_card != null:
		selected_card.is_clicked = false
		selected_card.card_dropped.emit(selected_card)

func _draw_cards():
	card_draw_sfx.play()
