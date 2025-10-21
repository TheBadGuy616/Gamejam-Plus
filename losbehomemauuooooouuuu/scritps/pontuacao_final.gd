extends Control

@export var pontos: Label
@onready var maxpontos: Label = $Panel/maxpontos

func _ready():
	update_max_points_label()
	update_points_label()

func update_max_points_label():
	maxpontos.text = str(Globais.update_maxpontos(Globais.points))

func update_points_label():
	pontos.text = str(Globais.points)
	Globais.points = 0

func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://Personagens/cena_teste.tscn")

func _on_opções_pressed() -> void:
	get_tree().change_scene_to_file("res://Interfaces/menuIniciar.tscn")
