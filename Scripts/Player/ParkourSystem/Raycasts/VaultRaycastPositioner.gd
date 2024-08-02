extends RayCast3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _get_new_vault_pos():
	# Verificar se antes o raycast colide com algo 
	if is_colliding():
		# Pegar o ponto de colisão
		var ground_point = get_collision_point()
		
		return ground_point
	
	return null
