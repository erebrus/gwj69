extends CardUI
class_name CustomCardUI
@onready var card_name: Label = $Frontface/Name

func _ready():
	super()
	card_data.connect("card_data_updated", _update_display)
	card_clicked.connect(_on_card_clicked)
	_update_display()
	
func _update_display():
	card_name.text = card_data.nice_name
	#cost_label.text = "%d" % card_data.cost
	#name_label.text = "%s" % card_data.nice_name			
	#type_label.text = "%s" % card_data.type
	#description_label.text = "%s" % card_data.description

func _on_card_clicked(card):
	if card == self:
		Logger.info("Clicked %s" % card_data.nice_name)
		card_data.play() 
		#TODO wait for card to be played before discarding
		Events.discard_requested.emit(self)
