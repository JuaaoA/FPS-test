extends RayCast3D


# Called when the node enters the scene tree for the first time.
func _check_raycast_collision():
	return is_colliding()

func _get_collision_distance():
	# Verificar se antes, está colidindo em algo
	if is_colliding():
		# Retornar distancia entre a origem do raycast e o ponto de colisão
		return global_position.distance_to(get_collision_point())

