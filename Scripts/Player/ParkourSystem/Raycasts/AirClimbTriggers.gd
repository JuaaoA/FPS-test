extends Node3D

var distance_to_dettect = 0.70

# Raycasts para o ponto mais alto
var top
var top_void

# Raycasts para o ponto mais baixo
var low
var low_void

# Raycast para posicionar o novo alvo de climb
var climb_ground

# Called when the node enters the scene tree for the first time.
func _ready():
	
	## TRIGGER PARA POSICIONAMENTO DO PONTO DE DESTINO DO CLIMB
	climb_ground = $ClimbTriggerGround
	
	## TRIGGERS LOCALIZADOS NO PONTO MAIS ALTO QUE O JOGADOR CONSEGUE ALCANÇAR
	top = $TopTrigger
	top_void = $TopTriggerVoid
	
	## TRIGGERS BAIXOS
	low = $LowTrigger
	low_void = $LowTriggerVoid

## ENCONTRAR UMA NOVA POSIÇÃO PARA O CLIMB
func _get_new_climb_pos(region: String):
	# region_point dirá qual é o ponto em que colide no chão 
	var region_point
	
	# Ver qual região do raycast foi selecionado
	match region:
		
		# Pegar o ponto que o raycast colide no chão
		"top":
			region_point = top._get_point()
		
		"low":
			region_point = low._get_point()
	
	# TODO Definir uma nova posição para o climb usando raycast
	#print(climb_ground.position, "old pos")
	#climb_ground.position = Vector3(region_point.x + 2, climb_ground.position.y, region_point.z)
	#print(climb_ground.position, "new pos")
	
	# TODO - POLIR MAIS O CLIMB
	
	# Retornar a posição 
	return climb_ground._get_point() + Vector3(0, 0.2, 0)

func _dettect_walls(region: String):
	## MATCH PARA ESCOLHER QUAL TRIGGER IRÁ SER ACIONADO
	match region:
		# Trigger no topo
		"top":
			# Se o trigger detectou uma parede agarrável
			return _top_trigger_check()
		
		# Trigger baixo
		"low":
			# Se detectou uma parede agarrável
			return _low_trigger_check()

func _low_trigger_check():
	return low._check_raycast_collision() and not low_void._check_raycast_collision()

func _top_trigger_check():
	return top._check_raycast_collision() and not top_void._check_raycast_collision()
