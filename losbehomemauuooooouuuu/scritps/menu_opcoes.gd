extends Control

func _on_opções_pressed() -> void:
	get_tree().change_scene_to_file("res://Interfaces/menuIniciar.tscn")

@export var volume_slider: HSlider
@export var percentage_label: Label

var master_bus_index = AudioServer.get_bus_index("Master")


func _ready():
	volume_slider.min_value = 0.0
	volume_slider.max_value = 100.0
	volume_slider.step = 1.0

	volume_slider.value = Globais.master_volume * 100.0
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(Globais.master_volume))
	
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	_update_percentage_label(volume_slider.value)


func _on_volume_slider_value_changed(slider_value: float):
	var linear_value = slider_value / 100.0
	Globais.master_volume = linear_value
	
	var db
	if linear_value == 0.0:
		db = -80.0
	else:
		db = linear_to_db(linear_value)
	
	AudioServer.set_bus_volume_db(master_bus_index, db)
	_update_percentage_label(slider_value)


func _update_percentage_label(value: float):
	percentage_label.text = "%d%%" % round(value)
	

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		$Panel/TextureRect7.visible = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$Panel/TextureRect7.visible = false
