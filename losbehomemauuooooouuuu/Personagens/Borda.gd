extends ColorRect

var current_tween: Tween

func _ready():
	# Garante que começa transparente, caso o valor padrão no shader esteja errado
	material.set_shader_parameter("fade_alpha", 0.0)

# Esta função será chamada pelo Jogador
func start_pulse(pulse_duration: float):
	
	# 1. Parar qualquer pulso anterior
	if current_tween and current_tween.is_running():
		current_tween.kill()
		
	# 2. Criar um novo Tween
	current_tween = create_tween()

	# 3. Animar a "ida" (Fade In - Aparecer)
	# Nós animamos a propriedade "shader_parameter/fade_alpha" do material
	current_tween.tween_property(
		material,                         # O objeto a animar (o material)
		"shader_parameter/fade_alpha",    # A propriedade (o uniform do shader)
		0.7,                              # O valor final (totalmente visível)
		pulse_duration                    # A duração
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 4. Animar a "volta" (Fade Out - Desaparecer)
	current_tween.tween_property(
		material,                         # O objeto a animar
		"shader_parameter/fade_alpha",    # A propriedade
		0.0,                              # O valor final (transparente)
		pulse_duration                    # A duração
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
