class_name Player
extends CharacterBody2D

@export var base_speed = 500.0       # Velocidade base
@export var speed_increase = 200.0    # Quanto a velocidade aumenta a cada nível
@export var base_friction = 200       # Novo: Adicione a fricção base
@export var friction_increase = 50.0
@export var nivel_limite = 5          # Quantos pontos para subir de nível
@export var dano_tempo_recebido = 2
@export var tempo = 10
@export var pontos = 0
@export var accel = 600
@export var friction = 200
@export var vida_label: Label
@onready var vida_timer = $VidaTimer
@onready var animacao_sprite = $Sprite2D
var tempo_vida_inicial: float = 0.0

var current_speed_modifier: float = 1.0
var current_max_speed: float
var last_checked_points: int = 0
var current_level: int = 0
var can_move = true

func _ready():
	# Inicializa a velocidade máxima com a velocidade base
	current_max_speed = base_speed
	if vida_timer != null:
		vida_timer.timeout.connect(_on_vida_timer_timeout)
		tempo_vida_inicial = vida_timer.wait_time
	else:
		print("ERRO: Nó do Timer de Vida não encontrado no Player.")
	
	if vida_label != null and vida_timer != null:
		vida_label.text = "%.3f" % vida_timer.wait_time
	elif vida_label == null:
		print("AVISO: 'Vida Label' não foi linkada no Inspetor do Player.")

	Globais.abate_registrado.connect(_on_globais_abate_registrado)


func _update_speed():
	# 1. Calcula o novo nível com base nos pontos globais
	var total_points = Globais.points
	var novo_nivel = int(total_points) / int(nivel_limite)
	# 2. Verifica se o Lobisomem subiu de nível
	if novo_nivel > current_level:
		current_level = novo_nivel
		
		# 3. Calcula a nova velocidade
	current_max_speed = base_speed + (float(current_level) * speed_increase)
	#print("Era: ", base_friction)
	base_friction = base_friction + (float(current_level) * friction_increase)
	#print("Agr: " , base_friction)
	
		
	#print("Nível de Velocidade Aumentado! Novo nível: ", current_level)
	#print("Nova velocidade máxima (speed): ", current_max_speed)
		
		# (Opcional) Tocar som ou mostrar efeito visual de aceleração
func _physics_process(delta):
	_update_speed()
	if can_move:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
		if direction != Vector2.ZERO:
			velocity = velocity.move_toward(direction * current_max_speed, accel * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	else:
		velocity.x = 0
		velocity.y = 0
	
	if velocity.x != 0 or velocity.y != 0:
		animacao_sprite.play("Walk")
	if velocity.x != 0:
		animacao_sprite.flip_h = velocity.x < 0
	
	
	move_and_slide()

func _process(delta):
	if vida_label != null and vida_timer != null:
		if vida_timer.is_stopped():
			if vida_timer.time_left == 0.0:
				vida_label.text = "0.00"
		else:
			vida_label.text = "%.3f" % vida_timer.time_left

func receber_dano_tempo():
	if vida_timer == null or (vida_timer.is_stopped() and vida_timer.time_left == 0.0):
		return
	
	vida_timer.stop()
	var novo_tempo_restante = vida_timer.time_left - dano_tempo_recebido
	print("Player atingido! Tempo restante: ", novo_tempo_restante)

	if novo_tempo_restante <= 0.0:
		vida_timer.wait_time = 0.0 
		_on_vida_timer_timeout()
	else:
		vida_timer.wait_time = novo_tempo_restante
		vida_timer.start()

func _on_globais_abate_registrado():
	if vida_timer == null:
		return
		
	print("PLAYER: Sinal de abate recebido! Timer de vida reiniciado.")
	
	vida_timer.stop()
	vida_timer.wait_time = tempo_vida_inicial
	vida_timer.start()
	
	if vida_label != null:
		vida_label.text = "%.3f" % tempo_vida_inicial

func apply_slow(factor: float):
	current_speed_modifier = factor
	
func remove_slow():
	current_speed_modifier = 1.0

func stop_movement_for_duration(duration:float):
	if can_move == false:
		return
	
	can_move = false
	var timer = Timer.new()
	add_child(timer)
	
	timer.one_shot = true
	timer.wait_time = duration
	timer.timeout.connect(_on_stun_timer_timeout)
	timer.start()

func _on_stun_timer_timeout():
	can_move = true
	var timer = get_node('Timer')
	if timer:
		timer.queue_free()
		
func _on_vida_timer_timeout():
	print("O tempo acabou! Jogador Morreu.")
	queue_free()
	get_tree().change_scene_to_file("res://Interfaces/menuIniciar.tscn")
