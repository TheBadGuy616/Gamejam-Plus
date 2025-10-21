extends Control

@export var pontos: Label
@onready var maxpontos: Label = $Panel/maxpontos

# Label que será criada dinamicamente
var aviso_recorde: Label
var aviso_tween: Tween

func _ready():
	update_max_points_label()
	update_points_label()

func update_max_points_label():
	var antigo_recorde = Globais.maxpontos
	var novo_recorde = Globais.update_maxpontos(Globais.points)
	maxpontos.text = str(novo_recorde)

	# Se houver novo recorde, mostra o aviso
	if Globais.points > antigo_recorde:
		_show_novo_recorde()

func update_points_label():
	pontos.text = str(Globais.points)
	Globais.points = 0

func _show_novo_recorde():
	# Carrega a fonte corretamente usando DynamicFont
	var font_resource = FontFile.new()
	var font_data = load("res://Assets/Minecraftia-Regular.ttf")
	font_resource.font_data = font_data

	if aviso_recorde == null:
		aviso_recorde = Label.new()
		aviso_recorde.text = "NOVO RECORDE!"
		aviso_recorde.add_theme_color_override("font_color", Color(1, 1, 0))  # Amarelo inicial
		aviso_recorde.add_theme_font_override("font", font_resource)
		aviso_recorde.add_theme_font_size_override("font_size", 30)
		aviso_recorde.modulate.a = 1.0
		aviso_recorde.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		aviso_recorde.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		aviso_recorde.anchor_left = 0.3
		aviso_recorde.anchor_right = 0.7
		aviso_recorde.anchor_top = 0.3
		aviso_recorde.anchor_bottom = 0.5
		aviso_recorde.global_position = Vector2(-250, 150)
		aviso_recorde.rotation_degrees = -35.0
		add_child(aviso_recorde)
		aviso_recorde.scale = Vector2(1, 1)
	
	# Cria Tween apenas para mudar cor
	if aviso_tween != null and aviso_tween.is_valid():
		aviso_tween.kill()

	aviso_tween = create_tween()
	aviso_tween.set_loops()  # loop infinito
	aviso_tween.tween_property(aviso_recorde, "modulate", Color(1, 1, 0), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	aviso_tween.tween_property(aviso_recorde, "modulate", Color(0.515, 1.0, 0.818, 1.0), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _remover_aviso_recorde():
	if aviso_tween != null and aviso_tween.is_valid():
		aviso_tween.kill()
	if aviso_recorde != null:
		aviso_recorde.queue_free()
		aviso_recorde = null

func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://Personagens/cena_teste.tscn")

func _on_opções_pressed() -> void:
	get_tree().change_scene_to_file("res://Interfaces/menuIniciar.tscn")
