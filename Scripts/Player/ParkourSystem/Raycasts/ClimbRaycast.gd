extends RayCast3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Se o raycast colidir com algo
	if (is_colliding()):
		
		# Pegar o objeto que foi colidido
		var obstacle = get_collider()
		
		# Se o objeto for um obstaculo
		if obstacle.is_in_group("obstacle"):
			# Fazer alguma coisa TODO
			print("CLIMB COLLIDE")
	pass
