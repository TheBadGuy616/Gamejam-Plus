extends Node

@export var points = 0
@export var master_volume: float = 0.5 # 0.0 a 1.0
var maxpontos = 0

signal abate_registrado
var intro_ja_tocou: bool = false

func registrar_abate_e_pontos(quantidade: int):
	points += quantidade
	print("Globais: Pontos atualizados! Total: ", points)
	abate_registrado.emit()

func update_maxpontos(pontuacao_final: int):
	if pontuacao_final > maxpontos:
		maxpontos = pontuacao_final
	return maxpontos
