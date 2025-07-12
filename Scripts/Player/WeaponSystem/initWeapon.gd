class_name WeaponController extends Node2D

## Arma que o jogador está usando
@export var WEAPON : Weapons:
	# Caso arma seja trocada
	set(value):
		# Trocar na variável
		WEAPON = value

		if Engine.is_editor_hint():
			_load_weapon()

# ser possivel mudar a textura TODO
@onready var weaponSprite : Sprite2D = $WeaponSprite
@onready var weaponAnimSprite : AnimatedSprite2D = $WeaponAnimSprite

# Definir uma rotação e posição fixa ## TODO RESOLVER ESSA RESOLUÇÃO PQ TA ERRADO
var baseSpritePosition : Vector2 = Vector2(1550, 785)
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
@export var idle_sway_speed : float = 1.5
var idle_sway_random_x : float
var idle_sway_random_y : float
var idle_sway_random_amount : float
var idle_sway_time : float
var idle_sway_weapon_speed_multiplier : float
var sway_time : float

# BOB SWAY - Movimento da arma enquanto andando
var bob_sway_random : Vector2

# AIR SWAY - Movimento da arma enquanto no ar
var air_sway_random : Vector2
var air_sway_intensity : float = 5
var air_sway_limit : float = 65

# Variáveis de controle da arma
var can_shoot : bool = true
var can_reload : bool = true
var pulling_weapon : bool = false

# Variáveis a serem usadas com o Resource da arma
var pulling_cooldown : float
var pulling_cooldown_timer : float = 0

# JOGADOR
@onready var player = get_node("/root/Level/Player")

# TODO TESTE
@export var primary : Weapons
@export var secondary : Weapons
@export var melee : Weapons

func _ready() -> void:
	# Iniciar o carregamento da arma
	_load_weapon()

# Verificar eventos de input
func _input(event):
	# Caso movimento seja do mouse
	if (event is InputEventMouseMotion):
		# Pegar movimento do mouse e guardar
		mouse_mov = event.relative

# Movimento da arma ao virar mouse ou ao estar parado
# delta - tempo desde o último frame
# is_idle - se o jogador está parado ou não
# Se o jogador estiver parado, será aplicado o idle sway
# Se o jogador estiver em movimento, será aplicado o sway de movimento
func weapon_sway(delta, is_idle:=true) -> void:
	# Ver se o jogador está parado
	if (is_idle):
		# Calcula velocidade do idle sway / Utiliza velocidade geral e da arma / Multiplica por 1000
		sway_time += delta * (idle_sway_speed * idle_sway_weapon_speed_multiplier * -0.0016) * 1000

		# Definir a amplitude do sway para ser adicionada ao movimento do lerp / Quanto maior o idle_sway_random_amount, maior o movimento
		# Multiplica por 1000 para ajustar a escala
		idle_sway_random_x = sin(sway_time * 1.5 + 0.1205) * (idle_sway_random_amount * 1000)
		idle_sway_random_y = sin(sway_time - 0.1205) * (idle_sway_random_amount * 1000)

	# TODO - fazer o sway em movimento
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
		(mouse_mov.x * sway_sensitivity_horizontal * WEAPON.sway_sensitivity_multiplier + idle_sway_random_x) * delta + bob_sway_random.x + air_sway_random.x,

		# Velocidade
		sway_speed * WEAPON.sway_speed_multiplier
	)

	# Movimentar a arma do jogador suavemente na vertical
	weaponSprite.position.y = lerp(
		# Posição inicial
		weaponSprite.position.y,

		# Movimentação da arma
		sway_initial_pos.y - 
		(mouse_mov.y * sway_sensitivity_vertical * WEAPON.sway_sensitivity_multiplier + idle_sway_random_y) * delta + bob_sway_random.y + air_sway_random.y,

		# Velocidade
		sway_speed * WEAPON.sway_speed_multiplier
	)

# Movimento da arma ao andar
# delta - tempo desde o último frame
# is_idle - se o jogador está parado ou não
# horiziontal_amount - quanto de movimento horizontal será aplicado
# vertical_amount - quanto de movimento vertical será aplicado
func weapon_bob(delta, is_idle : bool, speed : float, horizontal_amount : float, vertical_amount : float) -> void:
	# Bloquear a função caso o jogador esteja parado ou no ar
	if (is_idle or not player.is_on_floor()):
		# Manter bob sway em zero
		bob_sway_random = Vector2.ZERO
		return
 	
	# Calcular o tempo de bob com delta
	sway_time += delta 

	# Movimentar a arma do jogador suavemente na horizontal e vertical ao mesmo tempo
	bob_sway_random.x = sin(sway_time * speed) * (horizontal_amount * 100)
	bob_sway_random.y = abs(cos(sway_time * speed * 1.6) * (vertical_amount * 100))

# Movimento da arma no ar
# delta - tempo desde o último frame
# speed - velocidade do movimento
# is_on_air - se o jogador está no ar ou não
func weapon_air_sway(delta, intensity : float, is_on_air : bool) -> void:
	# Verificar se o jogador está no ar
	if (not is_on_air):
		# Manter air sway em zero
		air_sway_random = Vector2.ZERO
		return

	# Calcular o tempo de sway com delta
	sway_time += delta

	# Calcular o movimento da arma no ar de acordo com a velocidade do jogador
	air_sway_random.y = player.get_real_velocity().y * intensity

	# Clamp para limitar o movimento da arma no ar
	air_sway_random.y = clamp(air_sway_random.y, -air_sway_limit, air_sway_limit)

# Processamento de cada frame
func _process(delta):
	# Movimentar a arma de acordo com movimento do mouse e do jogador
	# Se o jogador estiver parado, será aplicado o idle sway
	weapon_sway(delta, player.is_idle())

	#  Movimentar a arma ao andar
 	# Se o jogador estiver parado, não será aplicado o bob
	# Se o jogador estiver no ar, não será aplicado o bob
	weapon_bob(delta, player.is_idle(), 1 * player.get_player_speed(), 0.18, 0.1)

	# Movimentar a arma no ar
	# Se o jogador estiver no ar, será aplicado o air sway
	weapon_air_sway(delta, air_sway_intensity, not player.is_on_floor())

	# Verificar cooldown de pull da arma
	# Se o jogador estiver puxando a arma, será aplicado o cooldown
	# Se não estiver puxando, essa função não fará nada
	pull_cooldown(delta)

	# TODO - APENAS PARA TESTE
	if (Input.is_action_just_pressed("primary_weapon")):
		set_weapon(primary, true)
	
	if (Input.is_action_just_pressed("secondary_weapon")):
		set_weapon(secondary, true)
	
	if (Input.is_action_just_pressed("melee_weapon")):
		set_weapon(melee, true)

# Carregar a arma
# Caso a variável WEAPON não esteja definida ou seja alterada, deverá carregar a arma
# Não deve ser chamado diretamente, mas sim através de set_weapon
func _load_weapon() -> void:
	# Definir sprite da arma
	weaponSprite.texture = WEAPON.weaponSprite

	# Definir ajuste de posição da arma
	weaponSprite.position = baseSpritePosition + WEAPON.positionOffset

	# Definir rotação da arma
	weaponSprite.rotation = baseSpriteRotation + WEAPON.rotationOffset

	# Definir posição inicial
	sway_initial_pos = weaponSprite.position

	# Definir idle sway
	idle_sway_random_amount = WEAPON.idle_anim_random_amount
	idle_sway_weapon_speed_multiplier = WEAPON.idle_anim_speed

	# Definir tempos da arma
	pulling_cooldown = WEAPON.pulling_time

# Definir nova arma e iniciar load
# newWeapon - nova arma a ser definida
# Chamará _load_weapon para carregar a nova arma
func set_weapon(newWeapon, pull_cooldown_activated:=false) -> void:
	if (newWeapon == WEAPON):
		# Se a arma já for a mesma, não fazer nada
		return

	# Definir nova arma
	WEAPON = newWeapon

	# Iniciar load da arma
	_load_weapon()

	# Iniciar cooldown de pull da arma caso esteja ativado
	if pull_cooldown_activated:
		start_pull_cooldown()

# Pegar informações da arma
# Retorna a arma que o jogador está usando
func get_weapon(): return WEAPON

# Iniciar o movimento de sacar a arma
# Essa função prepara a arma para ser puxada, assim, pull_cooldown será chamado na função _process
func start_pull_cooldown():
	# Iniciar cooldown de pull da arma
	pulling_weapon = true
	# Resetar o timer de cooldown
	pulling_cooldown_timer = 0

# Função de cooldown de pull da arma
# delta - tempo desde o último frame
# Essa função deve ser chamada a cada frame no _process
# Para iniciar o cooldown, deve-se chamar start_pull_cooldown()
func pull_cooldown(delta: float) -> void:
	# Evitar continuar caso o jogador não esteja puxando a arma
	if not pulling_weapon:
		return
	
	# Caso esteja puxando a arma
	pulling_cooldown_timer += delta

	# TODO - Mostrar para o jogador o tempo de cooldown / será feito uma animação de puxar a arma
	weaponSprite.modulate = Color(1, 1, 1, 0 + (pulling_cooldown_timer / pulling_cooldown))

	# Caso o tempo de cooldown tenha passado
	if pulling_cooldown_timer >= pulling_cooldown:
		# Resetar o timer
		pulling_cooldown_timer = 0
		# Parar de puxar a arma
		pulling_weapon = false

		## TODO - Voltar ao normal
		weaponSprite.modulate = Color(1, 1, 1, 1)
