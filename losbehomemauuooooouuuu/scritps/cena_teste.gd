extends Node2D

@export var audios: Array[AudioStream]
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	play_random_audio()

func _process(delta: float) -> void:
	pass

func play_random_audio():
	if audios.size() == 0:
		return
	var index = randi() % audios.size()
	audio_player.stream = audios[index]
	audio_player.play()
