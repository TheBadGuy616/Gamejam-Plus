extends Button

@export var multiplicador_hover: float = 1.1
@export var cor_hover: Color = Color(1.2, 1.2, 1.2)
@export var duracao_animacao: float = 0.2

var escala_normal: Vector2
var escala_hover: Vector2
var cor_normal: Color = Color(1.0, 1.0, 1.0) 


func _ready():
	# Define os valores base para as animações
	escala_normal = self.scale
	escala_hover = escala_normal * multiplicador_hover
	pivot_offset = size / 2.0
	
	# Conecta os sinais de hover
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# NÃO VAMOS MAIS ESCONDER O BOTÃO AQUI.
	# O Script do Menu Principal cuidará disso.

func _on_mouse_entered():
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", escala_hover, duracao_animacao)
	tween.tween_property(self, "modulate", cor_hover, duracao_animacao)

func _on_mouse_exited():
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", escala_normal, duracao_animacao)
	tween.tween_property(self, "modulate", cor_normal, duracao_animacao)


# Esta função ainda é chamada pelo Menu Principal
func run_intro_animation(duracao: float):
	self.visible = true # Torna o botão visível
	
	# Define o estado inicial da animação (agora que ele é visível)
	self.scale = escala_normal * 0.75
	self.modulate.a = 0.0
	
	var tween_entrada = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	tween_entrada.tween_property(self, "scale", escala_normal, duracao)
	tween_entrada.parallel().tween_property(self, "modulate:a", cor_normal.a, duracao * 0.5)
