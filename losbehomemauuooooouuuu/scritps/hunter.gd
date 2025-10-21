extends CharacterBody2D
class_name Hunter

@export var velocidade_fuga: float = 300.0
@export var velocidade_ociosa: float = 0.0
@export var projectile_scene: PackedScene

@onready var timer_de_disparo = $TimerDeDisparo
@onready var pivo_arma = $PivoArma
@onready var ponto_de_disparo = $PivoArma/PontoDeDisparo

@onready var animacao_sprite = $AnimatedSprite2D
@onready var animacao_arma = $PivoArma/AnimatedSprite2D_Arma
@onready var som_disparo: AudioStreamPlayer2D = $AudioStreamPlayer2D

var em_fuga: bool = false
var jogador_em_mira: bool = false
var lobisomem_alvo: CharacterBody2D = null

func _ready() -> void:
	animacao_arma.animation_finished.connect(_on_animacao_arma_finished)
	animacao_arma.play("Normal")

func _physics_process(_delta):
	var direcao_movimento = Vector2.ZERO
	var velocidade_atual = velocidade_ociosa
	
	if jogador_em_mira and is_instance_valid(lobisomem_alvo):
		velocidade_atual = 0.0 
		pivo_arma.look_at(lobisomem_alvo.global_position)
	
	elif em_fuga and is_instance_valid(lobisomem_alvo):
		var vetor_para_alvo = lobisomem_alvo.global_position - global_position
		direcao_movimento = -vetor_para_alvo.normalized()
		velocidade_atual = velocidade_fuga
		if direcao_movimento.x != 0:
			animacao_sprite.flip_h = direcao_movimento.x < 0
	
	velocity = direcao_movimento * velocidade_atual
	move_and_slide()

func _on_area_deteccao_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		lobisomem_alvo = body
		em_fuga = true
		animacao_sprite.play("Fugindo")

func _on_area_deteccao_body_exited(body: Node2D) -> void:
	if body == lobisomem_alvo:
		lobisomem_alvo = null
		em_fuga = false
		jogador_em_mira = false 
		timer_de_disparo.stop()
		animacao_sprite.play("parado")

func _on_alcance_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("DEBUG: Jogador ENTROU no Alcance.")
		lobisomem_alvo = body
		jogador_em_mira = true
		em_fuga = true
		timer_de_disparo.start()
		print("DEBUG: Timer de Disparo INICIADO.")

func _on_alcance_body_exited(body: Node2D) -> void:
	if body == lobisomem_alvo:
		print("DEBUG: Jogador SAIU do Alcance.")
		jogador_em_mira = false
		timer_de_disparo.stop()
		print("DEBUG: Timer de Disparo PARADO.")
		
		if is_instance_valid(lobisomem_alvo):
			em_fuga = true

func _on_ir_de_vala_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		await get_tree().process_frame
		$CollisionShape2D.disabled = true
		if body.has_node("Sprite2D"):
			var lobisomem_sprite = body.get_node("Sprite2D")
			lobisomem_sprite.play("Matando")
		Globais.registrar_abate_e_pontos(3)
		animacao_sprite.play("Morrendo")
		await animacao_sprite.animation_finished
		queue_free()

func _on_hurtbox_body_entered(body: Node2D):
	if body is Player:
		Globais.registrar_abate_e_pontos(1)
		print(name, " detectou o Lobisomem. Instakill!")
		queue_free()

func _on_timer_tiros_timeout() -> void:
	print("DEBUG: Timer TIMEOUT. Checando condições...")

	if projectile_scene == null:
		print("    FALHA: projectile_scene está nula. (Arraste Bala.tscn para o Inspetor do Hunter)")
		return

	if not jogador_em_mira:
		print("    FALHA: jogador_em_mira é false.")
		return
		
	if not is_instance_valid(lobisomem_alvo):
		print("    FALHA: lobisomem_alvo não é mais válido.")
		return
		
	print("    SUCESSO: Todas as condições OK. Disparando!")
	var bala = projectile_scene.instantiate()
	get_parent().add_child(bala)
	
	bala.global_position = ponto_de_disparo.global_position
	
	var direcao = (lobisomem_alvo.global_position - ponto_de_disparo.global_position).normalized()
	
	bala.rotation = direcao.angle() 
	
	if bala.has_method("set_direcao"):
		bala.set_direcao(direcao)
		
	if projectile_scene == null:
		print("FALHA: projectile_scene está nula.")
		return

	if not jogador_em_mira or not is_instance_valid(lobisomem_alvo):
		print("FALHA: Jogador fora de mira ou alvo inválido.")
		return
	print("SUCESSO: Todas as condições OK. Disparando!")
	executar_disparo()

func executar_disparo():
	
	# 1. INICIA A ANIMAÇÃO DE TIRO
	animacao_arma.play("Tiro")
	som_disparo.play()

	# 2. Lógica de Instanciação do Projétil (Tirada do seu _on_timer_tiros_timeout)
	var bala = projectile_scene.instantiate()
	get_parent().add_child(bala)
	
	bala.global_position = ponto_de_disparo.global_position
	
	var direcao = (lobisomem_alvo.global_position - ponto_de_disparo.global_position).normalized()
	
	bala.rotation = direcao.angle()
	
	if bala.has_method("set_direcao"):
		bala.set_direcao(direcao)

func _on_animacao_arma_finished():
	# Verifica se a animação que terminou é a de tiro (muito importante)
	if animacao_arma.animation == "Tiro":
		animacao_arma.play("Normal")
