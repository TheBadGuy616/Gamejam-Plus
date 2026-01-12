extends CanvasLayer

# --- VARIÁVEIS PÚBLICAS ---
var proxima_fase: PackedScene 

# --- REFERÊNCIAS ---
@onready var cenario_movel = $Node2D
@onready var lobisomem_sprite = $AnimatedSprite2D

# Itens internos
@onready var estudio = $Node2D/estudio
@onready var estudio2 = $Node2D/estudio2
@onready var claquete = $Node2D/claquete
@onready var claquete_sprite = $Node2D/claquete/AnimatedSprite2D 
@onready var escuro_gambiarra = $"Node2D/escuro gambiarra"
@onready var label_val_tomada = $"Node2D/claquete/val tomada"
@onready var label_val_pontos = $"Node2D/claquete/val pontos"
# Referência ao label que você quer controlar
@onready var label_acabou = $acabouu

var distancia_alvo = 0.0

func _ready():
	visible = false 
	layer = 100 
	
	if estudio: estudio.visible = false
	if estudio2: estudio2.visible = false
	if escuro_gambiarra: escuro_gambiarra.visible = false
	if lobisomem_sprite: lobisomem_sprite.visible = false
	if label_acabou: label_acabou.visible = false
	
	if claquete: 
		claquete.visible = true
		claquete.z_index = 100

	if estudio2: distancia_alvo = estudio2.position.x
	
	if lobisomem_sprite:
		lobisomem_sprite.position.x = 160
		lobisomem_sprite.rotation = 0
		lobisomem_sprite.scale = Vector2(1, 1)
	
	if cenario_movel: 
		cenario_movel.position = Vector2(0, 0)
		cenario_movel.scale = Vector2(1, 1)
		
	if "tentativas" in Globais and label_val_tomada:
		label_val_tomada.text = str(Globais.tentativas)
	if "points" in Globais and label_val_pontos:
		label_val_pontos.text = str(Globais.points)

func tocar_transicao():
	visible = true 
	iniciar_sequencia_claquete()

func iniciar_sequencia_claquete():
	if not claquete: return
	
	var tamanho_tela = get_viewport().get_visible_rect().size
	var pos_centro = tamanho_tela / 2
	var pos_final = Vector2(tamanho_tela.x + 100, tamanho_tela.y)
	
	claquete.position = Vector2(-200, tamanho_tela.y) 
	claquete.rotation_degrees = -45

	# 1. CLAQUETE ENTRA
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.tween_property(claquete, "position:x", pos_centro.x, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(claquete, "position:y", pos_centro.y, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(claquete, "rotation_degrees", 0.0, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	# 2. BATE A CLAQUETE
	if claquete_sprite: claquete_sprite.play("default")
	
	await get_tree().create_timer(0.8, true, false, true).timeout 
	
	# --- MOMENTO DA MÁGICA ---
	if estudio: estudio.visible = true
	if estudio2: estudio2.visible = true
	if escuro_gambiarra: escuro_gambiarra.visible = true 
	if lobisomem_sprite: lobisomem_sprite.visible = true
	
	# Mostra o label "Acabou"
	if label_acabou: label_acabou.visible = true
	
	trocar_fase_nos_bastidores()
	
	await get_tree().create_timer(0.1, true, false, true).timeout 

	# 3. CLAQUETE SAI
	var tween_saida = create_tween()
	tween_saida.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_saida.set_parallel(true)
	tween_saida.tween_property(claquete, "position:x", pos_final.x, 0.8).set_trans(Tween.TRANS_SINE)
	tween_saida.tween_property(claquete, "position:y", pos_final.y, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween_saida.tween_property(claquete, "rotation_degrees", 45.0, 0.8)
	await tween_saida.finished

	claquete.visible = false
	mover_cenario_completo()

func trocar_fase_nos_bastidores():
	if proxima_fase:
		print("Trocando de fase escondido...")
		get_tree().change_scene_to_packed(proxima_fase)
	else:
		printerr("ERRO: Nenhuma cena de 'Próxima Fase' foi definida!")

func mover_cenario_completo():
	# --- ALTERAÇÃO AQUI ---
	# 1. Espera 2 segundos com o label visível
	print("Esperando 2s com o label 'acabou' na tela...")
	await get_tree().create_timer(2.0, true, false, true).timeout
	
	# 2. Esconde o label
	if label_acabou: label_acabou.visible = false
	
	# 3. Espera o tempinho de 0.3s antes de começar a correr (que você pediu antes)
	await get_tree().create_timer(0.3, true, false, true).timeout
	
	# Animação da Corrida
	if lobisomem_sprite: lobisomem_sprite.play("default")
	
	var pos_final_cenario = Vector2(-distancia_alvo, 0)
	if cenario_movel:
		var tween_move = create_tween()
		tween_move.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween_move.tween_property(cenario_movel, "position", pos_final_cenario, 4.0).set_trans(Tween.TRANS_LINEAR)
		await tween_move.finished
	
	if lobisomem_sprite: lobisomem_sprite.stop()
		
	await get_tree().create_timer(0.5, true, false, true).timeout
	
	# --- ZOOM 13X ---
	print("Zoom 13x...")
	var tween_zoom = create_tween()
	tween_zoom.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_zoom.set_parallel(true)
	
	var escala_final = Vector2(13, 13)
	
	if cenario_movel and lobisomem_sprite:
		var pos_lobo = lobisomem_sprite.position
		var pos_cenario_atual = cenario_movel.position
		var nova_pos_cenario = pos_lobo - (pos_lobo - pos_cenario_atual) * 13.0
		
		tween_zoom.tween_property(cenario_movel, "scale", escala_final, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween_zoom.tween_property(cenario_movel, "position", nova_pos_cenario, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await tween_zoom.finished
	
	# --- FIM ---
	print("Transição completa.")
	get_tree().paused = false 
	queue_free()
