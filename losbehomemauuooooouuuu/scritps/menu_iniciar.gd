extends Control

# --- CONFIGURAÇÃO DA INTRO ---
@export var intro_video_path: String = "res://Assets/Composição-1.ogv"

# AQUI VAI OS BOTÕES E IMAGENS PARA ANIMAR
@export var nodes_para_animar: Array[Control]
# Duração da animação de "crescimento"
@export var duracao_animacao_entrada: float = 0.5


var video_player: VideoStreamPlayer

func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(Globais.master_volume))
	if not Globais.intro_ja_tocou:
		# 1. É A PRIMEIRA VEZ: Esconde todos os nós da UI
		for node in nodes_para_animar:
			node.visible = false
		
		# 2. Toca o vídeo
		video_player = VideoStreamPlayer.new()
		add_child(video_player)
		video_player.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		var video_stream = ResourceLoader.load(intro_video_path)
		
		if video_stream:
			video_player.stream = video_stream
			video_player.finished.connect(_on_intro_video_finished)
			video_player.play()
		else:
			# Se o vídeo falhar, pula direto para a animação
			_on_intro_video_finished()
	else:
		# 3. NÃO É A PRIMEIRA VEZ: Apenas mostra os nós
		for node in nodes_para_animar:
			node.visible = true


func _on_intro_video_finished():
	# 4. O VÍDEO ACABOU:
	Globais.intro_ja_tocou = true
	
	if video_player:
		video_player.queue_free()
		
	# 5. RODA A ANIMAÇÃO DE CRESCIMENTO!
	_run_intro_animation()


# ESTA FUNÇÃO FAZ A ANIMAÇÃO DE CRESCIMENTO (75% -> 100%)
func _run_intro_animation():
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Itera por todos os nós que você colocou no array
	for node in nodes_para_animar:
		# Define o ponto pivô para o centro (para escalar do centro)
		if node.has_method("get_size"):
			node.pivot_offset = node.get_size() / 2.0
		
		# Define o estado inicial (pequeno e transparente)
		node.scale = Vector2(0.75, 0.75)
		node.modulate.a = 0.0
		
		# Torna visível para animar
		node.visible = true 
		
		# Cria a animação de escala e fade-in em paralelo
		tween.parallel().tween_property(node, "scale", Vector2(1.0, 1.0), duracao_animacao_entrada)
		tween.parallel().tween_property(node, "modulate:a", 1.0, duracao_animacao_entrada * 0.5)

# --- Suas funções de botão originais ---

func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://Personagens/cena_teste.tscn")

func _on_opções_pressed() -> void:
	get_tree().change_scene_to_file("res://Interfaces/menuOpcoes.tscn")

func _on_sair_pressed() -> void:
	get_tree().quit()
