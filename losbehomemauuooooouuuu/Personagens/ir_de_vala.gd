extends Area2D

func _on_body_entered(body: CharacterBody2D):
	# 1. Verifica se o corpo que entrou é o Lobisomem
	if body is Player:
		
		# 2. Instakill:
		# A Hurtbox precisa referenciar o nó PAI (a Pessoa) para matá-lo.
		# get_parent() retorna o nó CharacterBody2D "Pessoa".
		var pessoa = get_parent()
		
		# Verificação de segurança (caso o nó pai não exista)
		if is_instance_valid(pessoa):
			print(pessoa.name, " foi tocada pelo Lobisomem. Instakill (chamado da Hurtbox).")
			
			# Chama a função de morte no nó pai (a Pessoa)
			# OU simplesmente chama queue_free() no pai.
			pessoa.queue_free()
			Globais.points += 1
			print("Pontos: ", Globais.points)
			# (OPCIONAL): Se você quiser que a Pessoa execute uma animação de morte,
			# o script pai (Pessoa.gd) precisa ter uma função 'morrer()', e você chamaria:
			# pessoa.morrer() 
			
	# Se o corpo não for o Lobisomem, o código ignora.
