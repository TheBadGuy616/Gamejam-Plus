extends Control

@export var pontos: Label

func _ready():
	update_points_label()

func update_points_label():
	pontos.text = str(Globais.points)
	

func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://Personagens/cena_teste.tscn")

func _on_opções_pressed() -> void:
	get_tree().change_scene_to_file("res://Interfaces/menuIniciar.tscn")
