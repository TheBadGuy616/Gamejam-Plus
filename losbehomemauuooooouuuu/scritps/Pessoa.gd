extends CharacterBody2D
class_name Pessoa # Define um nome de classe para facilitar a identificação

# --- Variáveis Exportáveis (ajustáveis no Inspetor) ---

@export var velocidade_fuga: float = 300.0 # Velocidade alta para fuga
@export var velocidade_ociosa: float = 0.0 # Movimento quando não vê o Lobisomem

# --- Variáveis de Estado ---

var em_fuga: bool = false
var lobisomem_alvo: CharacterBody2D = null
@onready var animacao_sprite = $AnimatedSprite2D
# --- Função Principal de Lógica de Jogo ---

func _physics_process(delta):
	var direcao_movimento = Vector2.ZERO
	var velocidade_atual = velocidade_ociosa
	
	# 1. Lógica de Fuga
	if em_fuga and is_instance_valid(lobisomem_alvo):
		
		# A. Calcula o Vetor (da Pessoa para o Lobisomem)
		var vetor_para_alvo = lobisomem_alvo.global_position - global_position
		
		# B. Inverte e Normaliza para obter a Direção de Fuga
		# O sinal de '-' inverte o vetor, garantindo que a Pessoa corra para o lado oposto.
		direcao_movimento = -vetor_para_alvo.normalized()
		velocidade_atual = velocidade_fuga
		
		if direcao_movimento.x != 0:
			animacao_sprite.flip_h = direcao_movimento.x < 0
	
	# 2. Aplica o Movimento
	
	# Define a nova velocidade do CharacterBody2D
	velocity = direcao_movimento * velocidade_atual
	
	# Move e Colide (função CharacterBody2D)
	move_and_slide()

# --- Lógica de Detecção (Sinais) ---

# OBS: É crucial que a cena do seu Lobisomem tenha um "class_name Lobisomem"
# ou esteja em um grupo chamado "lobo" para a detecção funcionar corretamente.

# Conecte o sinal 'body_entered' do nó 'AreaDeDeteccao' a esta função

func _on_area_deteccao_body_entered(body: Node2D) -> void:
	# Verifica se o corpo que entrou é o Lobisomem
	if body.is_in_group("Player"):
		lobisomem_alvo = body
		em_fuga = true
		animacao_sprite.play("Fugindo")
		#print("Pessoa: Lobisomem detectado! Fugindo...")

func _on_area_deteccao_body_exited(body: Node2D) -> void:
		# Verifica se o Lobisomem saiu da área de detecção
	if body == lobisomem_alvo:
		lobisomem_alvo = null
		em_fuga = false
		animacao_sprite.play("Parado")
		#print("Pessoa: Seguro por enquanto. Parando de correr.")


func _on_ir_de_vala_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Globais.registrar_abate_e_pontos(1)
		queue_free()

func _on_hurtbox_body_entered(body: Node2D):
	# Verificação de segurança (usando class_name Lobisomem)
	if body is Player:
		#print(name, " detectou o Lobisomem. Instakill!")
		
		# A Pessoa é o nó raiz deste script, então basta chamar queue_free()
		queue_free() 
		# Alternativamente, chame uma função de morte: morrer()
