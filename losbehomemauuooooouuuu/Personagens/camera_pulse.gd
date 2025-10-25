extends Camera2D

@export var pulse_strength: float = 1.3  # Quão forte é o pulso (1.0 = sem pulso, 1.2 = 20% zoom in)
@export var pulse_duration: float = 0.4 # Duração de cada fase (ida e volta)

var original_zoom: Vector2   # Para guardar o zoom original
var current_tween: Tween   # Para controlar a animação atual

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Salva o zoom inicial da câmera assim que o jogo começa
	original_zoom = zoom


# Called every frame. 'delta' is the elapsed time since the previous frame.
func start_pulse():
	# 1. Parar qualquer pulso anterior
	# Se um pulso já estiver acontecendo, pare-o e volte ao normal.
	# Isso evita que múltiplos pulsos "empilhem" e quebrem o zoom.
	if current_tween and current_tween.is_running():
		current_tween.kill() # Para a animação
		zoom = original_zoom # Restaura o zoom imediatamente

	# 2. Criar um novo Tween
	current_tween = create_tween()

	# 3. Definir o zoom "pulsado" (mais próximo)
	var pulsed_zoom: Vector2 = original_zoom * pulse_strength

	# 4. Animar a "ida" (Zoom In)
	# Anima a propriedade "zoom" DE SEU VALOR ATUAL para "pulsed_zoom"
	current_tween.tween_property(
		self,                # O nó a animar (a própria câmera)
		"zoom",              # A propriedade a animar
		pulsed_zoom,         # O valor final (zoom "in")
		pulse_duration       # A duração
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT) # Efeito de "suavização"

	# 5. Animar a "volta" (Zoom Out)
	# O Tween automaticamente coloca esta animação *depois* da anterior.
	current_tween.tween_property(
		self,                # O nó a animar
		"zoom",              # A propriedade a animar
		original_zoom,       # O valor final (volta ao original)
		pulse_duration       # A duração
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN) # Efeito de "suavização"
