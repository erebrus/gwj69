extends CardUI
class_name CustomCardUI

@onready var card_name: Label = %Name
@onready var image: TextureRect = %Image
@onready var description_label: Label = %Description

@onready var custom_data: CustomCardUIData = card_data as CustomCardUIData

signal card_drawn(card: CardUI)
signal card_played(card: CardUI)
signal card_discarded(card: CardUI)

func _ready():
	super()
	card_data.connect("card_data_updated", _update_display)
	card_clicked.connect(_on_card_clicked)
	custom_data.played.connect(_on_card_played)
	_update_display()
	
func _update_display():
	card_name.text = card_data.nice_name
	description_label.text = "%s" % card_data.description
	
	if (not card_data.image_path.is_empty()):
		image.texture = load(card_data.image_path)
		

func _on_card_clicked(card):
	if card == self:
		Logger.info("Clicked %s" % card_data.nice_name)
		custom_data.play()
		

func _on_card_played():
	Events.discard_requested.emit(self)
	card_played.emit(self)

func _on_card_drawn():
	pass
