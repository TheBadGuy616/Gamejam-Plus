extends Control

@export var volume_slider: HSlider
@export var percentage_label: Label

var master_bus_index = AudioServer.get_bus_index("Master")

func _ready():
	var current_db = AudioServer.get_bus_volume_db(master_bus_index)
	var current_linear = db_to_linear(current_db)
	
	# Conecta o sinal ANTES de definir o valor
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	
	# Agora, ao definir o 'value', o sinal 'value_changed' será emitido
	# e a função _on_volume_slider_value_changed fará todo o trabalho
	# (atualizar o áudio e o label) automaticamente.
	volume_slider.value = current_linear
	
	# Se o valor já for 0, o sinal pode não disparar,
	# então garantimos que o label esteja correto.
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
