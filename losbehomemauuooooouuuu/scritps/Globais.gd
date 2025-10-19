extends Node

@export var points = 0

signal abate_registrado

func registrar_abate_e_pontos(quantidade: int):
	points += quantidade
	print("Globais: Pontos atualizados! Total: ", points)
	abate_registrado.emit()
