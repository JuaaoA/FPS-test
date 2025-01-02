extends RayCast3D

# Pegar o ponto em que está colidindo
func get_point():
	return get_collision_point()


# Se o raycast está encostando numa parede ou não
func check_raycast_collision():
	return is_colliding()


# Pegar a distancia do point
func _get_collision_distance():
	# Verificar se antes, está colidindo em algo
	if is_colliding():
		# Retornar distancia entre a origem do raycast e o ponto de colisão
		return global_position.distance_to(get_collision_point())
