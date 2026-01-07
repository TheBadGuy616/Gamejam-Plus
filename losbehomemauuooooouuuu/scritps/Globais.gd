extends Node

@export var points = 0
@export var master_volume: float = 0.5 # 0.0 a 1.0
var maxpontos = 0
signal abate_registrado
var intro_ja_tocou: bool = false

const PASTA_JOGO := "Losbehomen"
const ARQUIVO_RECORDE := "recorde.json"

func _ready() -> void:
	carregar_recorde()

func registrar_abate_e_pontos(quantidade: int):
	points += quantidade
	print("Globais: Pontos atualizados! Total: ", points)
	abate_registrado.emit()

func update_maxpontos(pontuacao_final: int):
	if pontuacao_final > maxpontos:
		maxpontos = pontuacao_final
		salvar_recorde(pontuacao_final)
	return maxpontos

func get_caminho_recorde() -> String:
	var documentos = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	var pasta_jogo = documentos.path_join(PASTA_JOGO)

	# Cria a pasta se não existir
	if not DirAccess.dir_exists_absolute(pasta_jogo):
		DirAccess.make_dir_recursive_absolute(pasta_jogo)

	return pasta_jogo.path_join(ARQUIVO_RECORDE)

func salvar_recorde(recorde: int):
	var caminho = get_caminho_recorde()
	var arquivo = FileAccess.open(caminho, FileAccess.WRITE)

	if arquivo == null:
		push_error("Erro ao salvar recorde!")
		return

	var dados_salvos = {
		"maxpontos": recorde
	}

	arquivo.store_string(JSON.stringify(dados_salvos))
	arquivo.close()

func carregar_recorde():
	var caminho = get_caminho_recorde()

	if not FileAccess.file_exists(caminho):
		maxpontos = 0
		return

	var arquivo = FileAccess.open(caminho, FileAccess.READ)
	if arquivo == null:
		return

	var json = arquivo.get_as_text()
	var dados = JSON.parse_string(json)

	if typeof(dados) == TYPE_DICTIONARY and dados.has("maxpontos"):
		maxpontos = int(dados["maxpontos"])
	else:
		maxpontos = 0

	arquivo.close()
