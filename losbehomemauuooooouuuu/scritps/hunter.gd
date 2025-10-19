extends CharacterBody2D
class_name Hunter

@export var velocidade_fuga: float = 300.0
@export var velocidade_ociosa: float = 0.0
@export var projectile_scene: PackedScene

@onready var timer_de_disparo = $TimerDeDisparo
@onready var pivo_arma = $PivoArma
@onready var ponto_de_disparo = $PivoArma/PontoDeDisparo

var em_fuga: bool = false
var jogador_em_mira: bool = false
var lobisomem_alvo: CharacterBody2D = null

func _ready() -> void:
	timer_de_disparo.timeout.connect(_on_timer_tiros_timeout)

func _physics_process(delta):
	var direcao_movimento = Vector2.ZERO
	var velocidade_atual = velocidade_ociosa
	
	if jogador_em_mira and is_instance_valid(lobisomem_alvo):
		velocidade_atual = 0.0 
		pivo_arma.look_at(lobisomem_alvo.global_position)
	
	elif em_fuga and is_instance_valid(lobisomem_alvo):
		var vetor_para_alvo = lobisomem_alvo.global_position - global_position
		direcao_movimento = -vetor_para_alvo.normalized()
		velocidade_atual = velocidade_fuga
	
	velocity = direcao_movimento * velocidade_atual
	move_and_slide()

func _on_area_deteccao_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		lobisomem_alvo = body
		em_fuga = true

func _on_area_deteccao_body_exited(body: Node2D) -> void:
	if body == lobisomem_alvo:
		lobisomem_alvo = null
		em_fuga = false
		jogador_em_mira = false 
		timer_de_disparo.stop()

func _on_alcance_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		lobisomem_alvo = body
		jogador_em_mira = true
		em_fuga = false
		timer_de_disparo.start()

func _on_alcance_body_exited(body: Node2D) -> void:
	if body == lobisomem_alvo:
		jogador_em_mira = false
		timer_de_disparo.stop()
		
		if is_instance_valid(lobisomem_alvo):
			em_fuga = true

func _on_ir_de_vala_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		queue_free()
		Globais.points += 3

func _on_hurtbox_body_entered(body: Node2D):
	if body is Player:
		queue_free()


func _on_timer_tiros_timeout() -> void:
	if projectile_scene == null or not jogador_em_mira or not is_instance_valid(lobisomem_alvo):
		return

	var bala = projectile_scene.instantiate()
	get_parent().add_child(bala)
	
	bala.global_position = ponto_de_disparo.global_position
	
	var direcao = (lobisomem_alvo.global_position - ponto_de_disparo.global_position).normalized()
	
	bala.rotation = direcao.angle() 
	
	if bala.has_method("set_direcao"):
		bala.set_direcao(direcao)
	
