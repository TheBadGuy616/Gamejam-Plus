class_name Player
extends CharacterBody2D

@export var base_speed = 500.0       # Velocidade base
@export var speed_increase = 200.0    # Quanto a velocidade aumenta a cada nível
@export var base_friction = 200       # Novo: Adicione a fricção base
@export var friction_increase = 50.0
@export var nivel_limite = 5          # Quantos pontos para subir de nível

@export var tempo = 10
@export var pontos = 0
@export var accel = 600
@export var friction = 200

var current_max_speed: float
var last_checked_points: int = 0
	
var current_level: int = 0
var can_move = true

func _ready():
	# Inicializa a velocidade máxima com a velocidade base
	current_max_speed = base_speed
	

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
	move_and_slide()


func _on_timer_timeout() -> void:
	#get_tree().change_scene_to_file()
	pass
	
func on_enemy_death():
	pass

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
