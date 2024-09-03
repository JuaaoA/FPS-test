extends Node3D

var distance_to_dettect = 0.70

# Triggers para o ponto mais alto
var top
var top_void

#
var medium
var medium_void

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
	
	## TRIGGER LOCALIZADOS EM UM PONTO MÉDIO
	medium = null
	medium_void = null
	
	## TRIGGERS BAIXOS
	low = null
	low_void = null
	

## ENCONTRAR UMA NOVA POSIÇÃO PARA O CLIMB
func _get_new_climb_pos(region: String):
	
	var region_point
	
	# Ver qual região do raycast foi selecionado
	match (region):
		
		# Pegar o ponto que o raycast colide na parede
		"top":
			region_point = top._get_point()
		
		"medium":
			region_point = medium._get_point()
		
		"low":
			region_point = low._get_point()
	
	# TODO Definir uma nova posição para o climb usando raycast
	climb_ground.position = Vector3()
	

func _dettect_walls(region: String):
	
	## MATCH PARA ESCOLHER QUAL TRIGGER IRÁ SER ACIONADO
	match region:
		
		# Trigger no topo
		"top":
			# Se o trigger detectou uma parede agarrável
			if _top_trigger_check():
				print(top._get_collision_distance())
				return true
				
			
		
	
	
	pass

func _top_trigger_check():
	return top._check_raycast_collision() and not top_void._check_raycast_collision()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
