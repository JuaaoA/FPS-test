extends RayCast3D

var collision = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Se o raycast colidir com algo
	if (is_colliding()):
		
		# Pegar o objeto que foi colidido,
		var obstacle = get_collider()
		
		# Se o objeto for um obstaculo
		if obstacle.is_in_group("obstacle"):
			
			# Marcar como true a colisão
			collision = true
			
			# Retornar
			return
		
	# Caso não colida em nenhum objeto do grupo obstaculo
	collision = false

func _get_raycast_collision():
	return collision
