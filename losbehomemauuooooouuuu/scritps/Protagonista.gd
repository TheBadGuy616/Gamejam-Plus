class_name Player
extends CharacterBody2D

# --- CONFIGURAÇÕES DE MOVIMENTAÇÃO ---
@export_group("Movimentação Base")
@export var base_speed: float = 650.0  # Velocidade inicial
@export var accel: float = 700.0       # Aceleração inicial
@export var friction: float = 200.0    # Fricção FIXA (Isso faz ele escorregar nos niveis altos)

@export_group("Progressão (Level Up)")
@export var nivel_limite: int = 5         # Pontos necessários para subir de nível
# DICA: Como agora usamos curva, talvez você queira aumentar um pouco esses valores abaixo no Inspector
@export var speed_increase: float = 225.0 # Bônus base de velocidade
@export var accel_increase: float = 125.0 # Bônus base de aceleração

@export_group("Drift / Deslize")
@export var drift_min_speed_factor: float = 0.5
@export var drift_angle_threshold: float = 0.78 
@export var drift_particles: CPUParticles2D

@export_group("Combate e Vida")
@export var dano_tempo_recebido: float = 2.0
@export var vida_label: Label
@export var atacando_sfx: AudioStreamPlayer2D

@export_group("Referências")
@export var camera: Camera2D
@export var borda: Node
@export var texto_flutuante_scene: PackedScene
@onready var vida_timer: Timer = $VidaTimer
@onready var animacao_sprite: AnimatedSprite2D = $Sprite2D 

# Variáveis internas
var current_max_speed: float
var current_accel: float
var current_speed_modifier: float = 1.0
var current_level: int = 0
var tempo_vida_inicial: float = 0.0

var is_drifting: bool = false
var can_move: bool = true
var atacando: bool = false
var aviso_tween: Tween

func _ready():
	current_max_speed = base_speed
	current_accel = accel
	
	if vida_timer:
		tempo_vida_inicial = vida_timer.wait_time
		if vida_label: vida_label.text = "%.3f" % tempo_vida_inicial
		vida_timer.timeout.connect(_on_vida_timer_timeout)
	
	Globais.abate_registrado.connect(_on_globais_abate_registrado)

func _physics_process(delta):
	_atualizar_stats_nivel()
	
	var input_direction = Vector2.ZERO
	if can_move:
		input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if input_direction != Vector2.ZERO:
			velocity = velocity.move_toward(input_direction * current_max_speed, current_accel * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		velocity = Vector2.ZERO
	
	_processar_drift(delta, input_direction)
	_processar_animacao()
	move_and_slide()

func _process(_delta):
	_atualizar_ui()

# --- NOVA LÓGICA DE ESCALONAMENTO ---

func _atualizar_stats_nivel():
	var total_points = Globais.points
	if nivel_limite == 0: return
	
	var novo_nivel = int(total_points / nivel_limite)
	
	if novo_nivel > current_level:
		current_level = novo_nivel
		_efeitos_levelup()
	
	# FÓRMULA COM RAIZ QUADRADA (sqrt)
	# Isso garante que o crescimento desacelera conforme o nível sobe.
	# Nível 1: Multiplicador 1.0
	# Nível 4: Multiplicador 2.0
	# Nível 9: Multiplicador 3.0
	var multiplicador_curva = sqrt(current_level)
	
	current_max_speed = (base_speed + (multiplicador_curva * speed_increase)) * current_speed_modifier
	current_accel = (accel + (multiplicador_curva * accel_increase)) * current_speed_modifier

func _efeitos_levelup():
	uivo_level_up()
	musica_rapida()
	if camera: camera.start_pulse()
	if borda and borda.has_method("start_pulse"): 
		borda.start_pulse(camera.pulse_duration if camera else 0.5)
	_spawn_floating_text()

# --- RESTANTE DO CÓDIGO (INTOCADO) ---

func _processar_drift(delta, input_direction):
	var current_speed = velocity.length()
	var drift_condition = false
	
	if current_speed > current_max_speed * drift_min_speed_factor:
		if input_direction != Vector2.ZERO:
			var angle_diff = abs(velocity.normalized().angle_to(input_direction))
			if angle_diff > drift_angle_threshold:
				drift_condition = true
		elif input_direction == Vector2.ZERO:
			var friction_force = friction * delta
			if current_speed > friction_force * 3.0:
				drift_condition = true
	
	if drift_condition and not is_drifting:
		is_drifting = true
		if drift_particles: drift_particles.emitting = true
	elif not drift_condition and is_drifting:
		is_drifting = false
		if drift_particles: drift_particles.emitting = false

	if is_drifting and drift_particles and velocity.length_squared() > 0:
		drift_particles.rotation = velocity.angle() + deg_to_rad(-90)

func _processar_animacao():
	if velocity.length() > 0 or velocity.x != 0:
		if animacao_sprite.animation == "Matando" and not animacao_sprite.is_playing():
			animacao_sprite.play("Walk")
	
	if velocity.x != 0:
		animacao_sprite.flip_h = velocity.x < 0
	
	if animacao_sprite.animation == "Matando" and animacao_sprite.is_playing() and not atacando:
		if atacando_sfx: atacando_sfx.play()
		atacando = true

func _atualizar_ui():
	if vida_label and vida_timer:
		if vida_timer.is_stopped() and vida_timer.time_left == 0.0:
			vida_label.text = "0.00"
		else:
			vida_label.text = "%.3f" % vida_timer.time_left
		_checar_aviso_vida()

func _checar_aviso_vida():
	if vida_timer.time_left <= 5.5 and vida_timer.time_left > 0:
		if aviso_tween == null or not aviso_tween.is_valid():
			aviso_tween = create_tween().set_loops()
			aviso_tween.tween_property(vida_label, "modulate", Color(1, 0.2, 0.2), 0.3)
			aviso_tween.tween_property(vida_label, "scale", Vector2(1.75, 1.75), 0.3)
			aviso_tween.tween_property(vida_label, "scale", Vector2(1.0, 1.0), 0.3)
	else:
		if aviso_tween:
			aviso_tween.kill()
			aviso_tween = null
			vida_label.scale = Vector2.ONE
			vida_label.modulate = Color.WHITE

func receber_dano_tempo():
	if not vida_timer or (vida_timer.is_stopped() and vida_timer.time_left == 0.0): return
	vida_timer.stop()
	var novo_tempo = vida_timer.time_left - dano_tempo_recebido
	if novo_tempo <= 0.0:
		vida_timer.wait_time = 0.0
		_on_vida_timer_timeout()
	else:
		vida_timer.wait_time = novo_tempo
		vida_timer.start()

func _on_globais_abate_registrado():
	if not vida_timer: return
	vida_timer.stop()
	vida_timer.wait_time = tempo_vida_inicial
	vida_timer.start()
	if vida_label: vida_label.text = "%.3f" % tempo_vida_inicial

func _on_vida_timer_timeout():
	print("O tempo acabou! Jogador Morreu.")
	var musica_global = get_node_or_null("/root/MusicaFundo")
	if musica_global: musica_global.pitch_scale = 1.0
	call_deferred("_finalizar_morte")

func _finalizar_morte():
	queue_free()
	get_tree().change_scene_to_file("res://Interfaces/pontuacaoFinal.tscn")

func _spawn_floating_text():
	if not texto_flutuante_scene: return
	var ft = texto_flutuante_scene.instantiate()
	get_parent().add_child(ft)
	if ft.has_method("setup"):
		ft.setup("Speed UP+", global_position + Vector2(-250, -250), Color(0.83,0.06,0.06,1.0), self)

func apply_slow(factor: float):
	current_speed_modifier = factor
	_atualizar_stats_nivel()

func remove_slow():
	current_speed_modifier = 1.0
	_atualizar_stats_nivel()

func stop_movement_for_duration(duration: float):
	if not can_move: return
	can_move = false
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = duration
	timer.timeout.connect(func(): can_move = true; timer.queue_free())
	add_child(timer)
	timer.start()

func musica_rapida():
	var m = get_node_or_null("/root/MusicaFundo")
	if m: m.pitch_scale *= 1.1

func uivo_level_up():
	var p = get_parent()
	if p.has_method("play_random_audio"): p.play_random_audio()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Inimigos") or body.is_in_group("Obstaculo"):
		body.queue_free()
