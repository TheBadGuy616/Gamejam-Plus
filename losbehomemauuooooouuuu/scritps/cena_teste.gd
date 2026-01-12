extends Node2D

@export_category("Áudio")
@export var audios: Array[AudioStream]

@export_category("Transição de Fase")
@export var permitir_animacao: bool = true 
# Aqui você arrasta o arquivo "TrocaDeFase.tscn"
@export var cena_transicao: PackedScene
# AQUI VOCÊ ARRASTA A PRÓXIMA FASE (Ex: Fase2.tscn)
@export var proxima_fase: PackedScene 

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	play_random_audio()

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_M:
			if permitir_animacao:
				chamar_transicao()

func chamar_transicao():
	# Verifica se temos a transição E a próxima fase configuradas
	if cena_transicao and proxima_fase:
		
		# 1. Instancia a transição
		var nova_transicao = cena_transicao.instantiate()
		
		# 2. Passa a informação de qual fase carregar
		nova_transicao.proxima_fase = proxima_fase
		
		# 3. Adiciona na raiz (por cima de tudo)
		get_tree().root.add_child(nova_transicao)
		
		# 4. Pausa o jogo atual
		get_tree().paused = true
		
		# 5. Toca a animação
		nova_transicao.tocar_transicao()
		
	else:
		printerr("ERRO: Configure 'Cena Transicao' e 'Proxima Fase' no Inspector!")

func play_random_audio():
	if audios.size() == 0: return
	var index = randi() % audios.size()
	audio_player.stream = audios[index]
	audio_player.play()
