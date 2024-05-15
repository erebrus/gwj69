extends CardUI
class_name CustomCardUI

@onready var card_name: Label = %Name
@onready var image: TextureRect = %Image
@onready var description_label: Label = %Description
@onready var one_use: TextureRect = $Frontface/MarginContainer4/VBoxContainer/OneUse

@onready var custom_data: CustomCardUIData = card_data as CustomCardUIData

signal card_shuffled_to_draw(card: CardUI)
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
	if (custom_data.display_name.is_empty()):
		card_name.text = custom_data.nice_name
	else:
		card_name.text = custom_data.display_name
		
	description_label.text = "%s" % custom_data.description
	one_use.visible = custom_data.has_trait(CustomCardUIData.Traits.ONE_USE)
	if (not custom_data.image_path.is_empty()):
		image.texture = load(custom_data.image_path)
		

func _on_card_clicked(card):
	if card == self:
		Logger.info("Clicked %s" % card_data.nice_name)
		custom_data.play()
		
func set_pile(value: CardPileUI.Piles) -> void:
	if value != pile:
		super.set_pile(value)
		if in_discard():
			card_discarded.emit(self)
		elif in_hand():
			card_drawn.emit(self)
		elif in_draw():
			card_shuffled_to_draw.emit(self)

func _on_card_played():
	Events.discard_requested.emit(self)
	card_played.emit(self)
	#HACK logic shouldn't be here...
	if custom_data.has_trait(CustomCardUIData.Traits.ONE_USE):
		Events.card_destroy_requested.emit(self)
func _on_card_drawn():
	pass
