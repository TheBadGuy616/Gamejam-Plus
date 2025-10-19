extends Control

@export var opcoes: PackedScene

func _on_jogar_pressed() -> void:
	pass # Replace with function body.

func _on_opções_pressed() -> void:
	get_tree().change_scene_to_file("res://Interfaces/menuOpcoes.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()
