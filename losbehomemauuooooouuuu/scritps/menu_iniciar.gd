extends Control

func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://Personagens/cena_teste.tscn")

func _on_opções_pressed() -> void:
	get_tree().change_scene_to_file("res://Interfaces/menuOpcoes.tscn")

func _on_sair_pressed() -> void:
	get_tree().quit()
