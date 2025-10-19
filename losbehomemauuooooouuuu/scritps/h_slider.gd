extends HSlider

@export var percentage_label: Label

var master_bus_index = AudioServer.get_bus_index("Master")

func _ready():
	var current_db = AudioServer.get_bus_volume_db(master_bus_index)
	var current_linear = db_to_linear(current_db)
	
	_update_percentage_label(current_linear)
	


func _on_volume_slider_value_changed(value: float):
	var db
	if value == 0.0:
		db = -80.0
	else:
		db = linear_to_db(value)
	
	AudioServer.set_bus_volume_db(master_bus_index, db)
	_update_percentage_label(value)


func _update_percentage_label(value: float):
	percentage_label.text = "%d%%" % (value * 100)
