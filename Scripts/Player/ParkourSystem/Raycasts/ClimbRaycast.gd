extends RayCast3D

var collision = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Se o raycast colidir com algo
	if (is_colliding()):
		
		# Pegar o objeto que foi colidido
		var obstacle = get_collider()
		
		# Se o objeto for um obstaculo
		if obstacle.is_in_group("obstacle"):
			
			# Marcar a colisão como true
			collision = true
			
			# Retornar
			return
			
	# Caso tudo seja falso, manter falso
	collision = false

func _get_raycast_collision():
	return collision

func _get_raycast_collision_point():
	return get_collision_point()
