extends Node2D

# --- Variáveis de Configuração ---
@onready var text_label = $TextLabel
@export var float_distance: float = 50.0  # O quanto o texto vai subir
@export var duration: float = 1.0        # Duração da animação

# --- Variáveis de Lógica Interna ---
var target_to_follow: Node2D = null # O nó que vamos seguir (o Player)
var follow_offset: Vector2 = Vector2.ZERO # A diferença X e Y inicial

# --- Função de Setup Modificada ---
func setup(text: String, start_position: Vector2, text_color: Color = Color.WHITE, target: Node2D = null):
	text_label.text = text
	text_label.add_theme_color_override("font_color", text_color)
	global_position = start_position
	
	target_to_follow = target
	
	# Se tivermos um alvo, calculamos nosso "offset" X e Y
	# Este offset é a diferença inicial entre o texto e o jogador
	# Ex: Vector2(0, -30) - "fique 30 pixels acima do jogador"
	if target_to_follow:
		follow_offset = global_position - target_to_follow.global_position


# --- Função de Animação Modificada ---
func _ready():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 1. Animar o Movimento (para cima)
	# !!! MUDANÇA IMPORTANTE !!!
	# Agora animamos o NÓ FILHO (TextLabel), não o nó pai (self)
	tween.tween_property(
		text_label,                            # O nó a animar (o Label)
		"position:y",                          # A propriedade (posição Y local)
		text_label.position.y - float_distance,# O valor final Y
		duration                               
	).set_ease(Tween.EASE_OUT)

	# 2. Animar o Fade Out (desaparecer)
	# Este tween ainda se aplica ao nó pai (self)
	# para que o texto e seus efeitos desapareçam juntos.
	tween.tween_property(
		self, "modulate:a", 0.0, duration * 0.5
	).set_delay(duration * 0.5)
	
	# 3. Autodestruição
	tween.finished.connect(queue_free)


# --- FUNÇÃO "SEGUIDOR" MODIFICADA ---
# Esta função roda a cada frame
func _process(delta):
	# Se tivermos um alvo definido...
	if target_to_follow:
		# Atualize nossa posição GLOBAL para ser a posição GLOBAL do alvo + o offset salvo
		global_position = target_to_follow.global_position + follow_offset
