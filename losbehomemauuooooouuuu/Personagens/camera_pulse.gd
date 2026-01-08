extends Camera2D

# --- CONFIGURAÇÕES DE CÂMERA ---
@export_group("Configuração de Zoom")
@export var zoom_inicial: float = 2.5 # Aumente esse valor para aproximar (tente 3.0, 4.0 ou 5.0)

@export_group("Efeito de Pulso (Level Up)")
@export var pulse_strength: float = 1.3  # Quão forte é o pulso (multiplicador do zoom atual)
@export var pulse_duration: float = 0.4 

var original_zoom: Vector2   # Para guardar o zoom base
var current_tween: Tween     # Para controlar a animação atual

func _ready() -> void:
	# APLICA O ZOOM INICIAL
	# Isso garante que a câmera comece perto o suficiente dos sprites novos
	zoom = Vector2(zoom_inicial, zoom_inicial)
	
	# Salva esse novo zoom como o "original" para o efeito de pulso voltar pra cá depois
	original_zoom = zoom

func start_pulse():
	# 1. Parar qualquer pulso anterior
	if current_tween and current_tween.is_running():
		current_tween.kill()
		zoom = original_zoom # Restaura o zoom imediatamente

	# 2. Criar um novo Tween
	current_tween = create_tween()

	# 3. Definir o zoom "pulsado" (AINDA MAIS próximo que o zoom inicial)
	var pulsed_zoom: Vector2 = original_zoom * pulse_strength

	# 4. Anima a "ida" (Zoom In)
	current_tween.tween_property(
		self, 
		"zoom", 
		pulsed_zoom, 
		pulse_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 5. Anima a "volta" (Zoom Out para o zoom inicial)
	current_tween.tween_property(
		self, 
		"zoom", 
		original_zoom, 
		pulse_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
