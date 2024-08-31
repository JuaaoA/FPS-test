extends Node3D

# Triggers para o ponto mais alto
var top
var top_void

#
var medium
var medium_void

var low
var low_void

# Called when the node enters the scene tree for the first time.
func _ready():
	
	## TRIGGERS LOCALIZADOS NO PONTO MAIS ALTO QUE O JOGADOR CONSEGUE ALCANÇAR
	top = $TopTrigger
	top_void = $TopTriggerVoid
	
	## TRIGGER LOCALIZADOS EM UM PONTO MÉDIO
	medium = null
	medium_void = null
	
	## TRIGGERS BAIXOS
	low = null
	low_void = null
	

func _dettect_walls(region):
	
	## MATCH PARA ESCOLHER QUAL TRIGGER IRÁ SER ACIONADO
	match region:
		
		# Trigger no topo
		"top":
			# Se o trigger detectou uma parede agarrável
			if _top_trigger_check():
				print("TOP CLIMB EDGE")
				print(top._get_collision_distance())
				
		
	
	
	pass

func _top_trigger_check():
	return top._check_raycast_collision() and not top_void._check_raycast_collision()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
