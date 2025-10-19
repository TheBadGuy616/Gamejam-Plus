extends Area2D

@export var velocidade_bala: float = 600.0
@export var tempo_vida: float = 3.0

var direcao: Vector2 = Vector2.RIGHT

func _ready() -> void:
	var timer_morte = Timer.new()
	timer_morte.wait_time = tempo_vida
	timer_morte.one_shot = true
	timer_morte.timeout.connect(queue_free)
	add_child(timer_morte)
	timer_morte.start()
	
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direcao * velocidade_bala * delta

func set_direcao(nova_direcao: Vector2) -> void:
	direcao = nova_direcao.normalized()
	rotation = direcao.angle()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		queue_free()
	
	elif body.is_in_group("Obstaculo"):
		queue_free()
