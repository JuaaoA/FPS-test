extends Node2D

## Arma que o jogador está usando
@export var WEAPON : Weapons:
	# Caso arma seja trocada
	set(value):
		# Trocar na variável
		WEAPON = value

		if Engine.is_editor_hint():
			load_weapon()

# ser possivel mudar a textura TODO
@onready var weaponSprite : Sprite2D = $WeaponSprite

# Definir uma rotação e posição fixa ## TODO RESOLVER ESSA RESOLUÇÃO PQ TA ERRADO
var baseSpritePosition : Vector2 = Vector2(1550, 825)
var baseSpriteRotation : float = 0

# Movimento do mouse
var mouse_mov : Vector2

# SWAY - Movimento da arma
var sway_initial_pos : Vector2
var sway_sensitivity_horizontal : float = 100
var sway_sensitivity_vertical : float = 90
var sway_speed : float = 0.75
var sway_min : Vector2 = Vector2(-150, -90)
var sway_max : Vector2 = Vector2(150, 70)

# IDLE SWAY - Movimento da arma enquanto parado
@export var idle_sway_noise_texture : NoiseTexture2D
@export var idle_sway_speed : float = 1.5
var idle_sway_random_x : float
var idle_sway_random_y : float
var idle_sway_random_amount : float
var idle_sway_time : float
var idle_sway_adjustment
var idle_sway_rotation_strength
var sway_time : float

# JOGADOR
@onready var player = get_node("/root/Level/Player")

# TODO TESTE
@export var primary : Weapons
@export var secondary : Weapons
@export var melee : Weapons

func _ready() -> void:
	# Iniciar o carregamento da arma
	load_weapon()

# Verificar eventos de input
func _input(event):
	# Caso movimento seja do mouse
	if (event is InputEventMouseMotion):
		# Pegar movimento do mouse e guardar
		mouse_mov = event.relative

# Movimento da arma ao virar mouse
func weapon_sway(delta) -> void:
	#
	var sway_randomizer : float = get_sway_noise()
	var sway_randomizer_adjust = sway_randomizer * idle_sway_adjustment

	#
	sway_time += delta * (idle_sway_speed * sway_randomizer) * 1000

	print(sway_time)

	#
	idle_sway_random_x = sin(sway_time * 1.5 + sway_randomizer_adjust) / idle_sway_random_amount * 1000
	idle_sway_random_y = sin(sway_time - sway_randomizer_adjust) / idle_sway_random_amount * 1000

	# Fazer o movimento do mouse tender a zero (evitar problemas caso o evento pare totalmente)
	mouse_mov = lerp(mouse_mov, Vector2(0,0), 0.1)

	# Limitar a movimentação
	mouse_mov = mouse_mov.clamp(sway_min, sway_max)

	# Movimentar a arma do jogador suavemente na horizontal
	weaponSprite.position.x = lerp(
		# Posição inicial
		weaponSprite.position.x,

		# Movimentação da arma
		sway_initial_pos.x - 
		(mouse_mov.x * sway_sensitivity_horizontal * WEAPON.sway_sensitivity_multiplier + idle_sway_random_x) * delta,

		# Velocidade
		sway_speed * WEAPON.sway_speed_multiplier
	)

	# Movimentar a arma do jogador suavemente na vertical
	weaponSprite.position.y = lerp(
		# Posição inicial
		weaponSprite.position.y,

		# Movimentação da arma
		sway_initial_pos.y - 
		(mouse_mov.y * sway_sensitivity_vertical * WEAPON.sway_sensitivity_multiplier + idle_sway_random_y) * delta,

		# Velocidade
		sway_speed * WEAPON.sway_speed_multiplier
	)

# Criar noise para sway aleatório
func get_sway_noise() -> float:
	# Definir um local vazio
	var player_location := Vector3(0, 0, 0)

	# Caso já tenha iniciado o _ready()
	if (not Engine.is_editor_hint()):
		player_location = player.global_position

	# Criar um noise de acordo
	var noise_location : float = idle_sway_noise_texture.noise.get_noise_2d(player_location.x, player_location.y)
	
	# Retornar noise criado
	return noise_location

func _physics_process(delta):
	# Movimentar a arma de acordo com movimento do mouse
	weapon_sway(delta)

# TODO TESTE
func _process(delta):
	if (Input.is_action_just_pressed("primary_weapon")):
		set_weapon(primary)
	
	if (Input.is_action_just_pressed("secondary_weapon")):
		set_weapon(secondary)
	
	if (Input.is_action_just_pressed("melee_weapon")):
		set_weapon(melee)

# Carregar a arma
func load_weapon() -> void:
	# Definir sprite da arma
	weaponSprite.texture = WEAPON.weaponSprite

	# Definir ajuste de posição da arma
	weaponSprite.position = baseSpritePosition + WEAPON.positionOffset

	# Definir rotação da arma
	weaponSprite.rotation = baseSpriteRotation + WEAPON.rotationOffset

	# Definir posição inicial
	sway_initial_pos = weaponSprite.position

	# Definir idle sway
	idle_sway_adjustment = WEAPON.idle_anim_adjust
	idle_sway_rotation_strength = WEAPON.idle_anim_amplitude
	idle_sway_random_amount = WEAPON.idle_anim_random_amount

# Definir nova arma
func set_weapon(newWeapon) -> void:
	# Definir nova arma
	WEAPON = newWeapon

	# Iniciar load da arma
	load_weapon()

# Pegar informações da arma
func get_weapon(): return WEAPON
