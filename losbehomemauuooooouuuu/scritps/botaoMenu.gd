extends Button

@export var multiplicador_hover: float = 1.1
@export var cor_hover: Color = Color(1.2, 1.2, 1.2)
@export var duracao_animacao: float = 0.2

var escala_normal: Vector2
var escala_hover: Vector2
var cor_normal: Color = Color(1.0, 1.0, 1.0) 


func _ready():
	escala_normal = self.scale
	escala_hover = escala_normal * multiplicador_hover
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pivot_offset = size / 2.0

func _on_mouse_entered():
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "scale", escala_hover, duracao_animacao)
	tween.tween_property(self, "modulate", cor_hover, duracao_animacao)

func _on_mouse_exited():
	var tween = create_tween().set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "scale", escala_normal, duracao_animacao)
	tween.tween_property(self, "modulate", cor_normal, duracao_animacao)
