extends CenterContainer

# PROPRIEDADES MIRA ADAPTAVEL ARMA
@export var RETICLE_LINES : Array[Line2D]
@export var PLAYER : CharacterBody3D
@export var RETICLE_SPEED : float = 0.30
@export var RETICLE_DISTANCE : float = 2.0

# PROPRIEDADES DA MIRA PONTO
@export var DOT_RADIUS : float = 1.6
@export var DOT_COLOR : Color = Color.WHITE

# OBJETO OUTRAS MIRAS
@onready var aimReticle = $Aim
@onready var aimOcuppied = $Ocuppied
@onready var aimCustom = $Custom

# Called when the node enters the scene tree for the first time.
func _ready():
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	# Definir qual mira será mostrada
	_define_crosshair()

	# Ajustar linhas da mira, se tiver
	adjust_aim_reticle_lines()

func _draw():
	draw_circle(Vector2(0, 0), DOT_RADIUS, DOT_COLOR)

func _define_crosshair():
	# Pegar nas infos do jogador o que o jogador está fazendo
	var player_state = PLAYER.get_moviment_state()

	# Se as mãos estiverem ocupadas
	match (player_state):

		# Mãos ocupadas
		"hands_ocuppied":
			# Desativar outras miras
			_deactivate_aim()
			_deactivate_custom()

			# Mostrar mira ocupada
			_activate_ocuppied()
		
		# Mão com arma
		"armed":
			# Desativar outras miras
			_deactivate_ocuppied()
			_deactivate_custom()

			# Ativar mira
			_activate_aim()
		
		# Mãos livres
		"hands_free":
			# Desativar todas as miras
			_deactivate_aim()
			_deactivate_ocuppied()
			_deactivate_custom()
		
		# Caso customizado
		_:
			# Desativar todas as miras
			_deactivate_aim()
			_deactivate_ocuppied()
			
			# Ativar customizado
			_activate_custom(player_state)

func _activate_custom(state_crosshair):
	# Mostrar mira
	aimCustom.visible = true

	# Definir novo sprite da mira
	aimCustom.change_sprite(state_crosshair)

func _deactivate_custom():
	aimCustom.visible = false

func  _activate_ocuppied():
	aimOcuppied.visible = true

func  _deactivate_ocuppied():
	aimOcuppied.visible = false

func _activate_aim():
	aimReticle.visible = true

func _deactivate_aim():
	aimReticle.visible = false

func adjust_aim_reticle_lines():
	
	# Impedir de continuar caso não esteja visível a mira
	if (not aimReticle.visible):
		return
	
	## Ajustar valores da mira
	# Velocidade do jogador
	var player_velocity = PLAYER.get_real_velocity()

	# Ponto de origem
	var origin = Vector3(0, 0, 0)

	# Posicão origem 2D
	var org_pos = Vector2(0, 0)

	# Velocidade
	var speed = origin.distance_to(player_velocity)
	
	## Ajustar MIRA
	RETICLE_LINES[0].position = lerp(RETICLE_LINES[0].position, org_pos + Vector2(0, -speed * RETICLE_DISTANCE), RETICLE_SPEED)
	RETICLE_LINES[1].position = lerp(RETICLE_LINES[1].position, org_pos + Vector2(speed * RETICLE_DISTANCE, 0), RETICLE_SPEED)
	RETICLE_LINES[2].position = lerp(RETICLE_LINES[2].position, org_pos + Vector2(0, speed * RETICLE_DISTANCE), RETICLE_SPEED)
	RETICLE_LINES[3].position = lerp(RETICLE_LINES[3].position, org_pos + Vector2(-speed * RETICLE_DISTANCE, 0), RETICLE_SPEED)
