extends Control

@export var iniciar: PackedScene

func _on_opções_pressed() -> void:
	get_tree().change_scene_to_file("res://Interfaces/menuIniciar.tscn")
