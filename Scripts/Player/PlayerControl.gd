extends CharacterBody3D

# Constantes para corrida
const faster_run_speed = 12
const run_speed = 8.0
const walk_speed = 4.0

# Segundos para ativar a corrida
const trigger_run = 5
const trigger_faster_run = 10

# Variável para contar quanto tempo o jogador está correndo
var running_time = 0

# Variável para contar quanto tempo o jogador está virando
var turning_time = 0

# Variável para o movimento de olhar do jogador
var direction = 0

# Constante para pulo
const jump_velocity = 4.5

# Constante para sensibilidade do olhar
const sensitivity = 0.005

# Velocidade do jogador atual, só é usado quando o jogo está rodando
var current_speed = 0

# Constantes para o FOV
const BASE_FOV = 80
const FOV_CHANGE = 1.3

# Constantes para a cabeça mexer ao andar
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

var t_target = 0

# Gravidades

# Gravidade normal, sem o jogador estar escalando ou realizando wallrun
var normal_gravity = 9.8

# WALLRUN
var wallrun_gravity = 5.5
var wallrun_last_wall_distance = null
var wallrun_wall_normal = null
var wallrun_wall_direction = null
var wallrun_min_vertical_velocity = -5
var wallrun_head_tilt = 0.25
var wallrun_horizontal_force = 3
var wallrun_vertical_force = 7

# Esse cooldown evita outros movimentos quando o jogador sai do wallrun
var post_wallrun_cooldown = 0.35
var post_wallrun_cooldown_current = 0

# POSIÇÕES VAULT
var vault_last_pos = null

# POSIÇÕES CLIMB
var climb_target_pos = null

# WALL CLIMB
var wallclimb_horizontal_force = 8
var wallclimb_vertical_force = 8

# ROTAÇÃO FAST TURN
var initial_head_rotation = null
var target_head_rotation = null

# BOLEANAS
var wallrunning = false
var climbing = false
var vaulting = false
var enable_gravity = true
var can_look = true
var turning = false

# Objetos da camera e cabeça
@onready var head = $PlayerHead
@onready var camera = $PlayerHead/PlayerCamera

# Objetos para o raycast
@onready var vaultRaycast = $PlayerHead/PlayerTriggers/VaultRaycast
@onready var climbRaycast = $PlayerHead/PlayerTriggers/ClimbRaycast
@onready var vaultPositioner = $PlayerHead/VaultRaycastPositioner/VaultPositioner
@onready var airClimb = $PlayerHead/PlayerTriggers/AirClimbTriggers
@onready var backwardRaycast = $PlayerHead/PlayerTriggers/AirClimbTriggers/BackwardTrigger
@onready var wallrun_right = $PlayerHead/PlayerTriggers/WallRunTriggers/WallRunRightRaycast
@onready var wallrun_left = $PlayerHead/PlayerTriggers/WallRunTriggers/WallRunLeftRaycast

func _ready():
	# Deixar o mouse travado ao iniciar o jogo
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	
	# Se o evento que acontecer for um movimento de mouse e se o jogador pode olhar
	if event is InputEventMouseMotion and can_look:
		
		# Rotacionar cabeça e camera
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		
		# Limitar a camera para um valor minimo ou máximo
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(60))

func _calculate_auto_running(delta):
	# Iniciar corrida automática
	# O jogador correrá automaticamente após andar por alguns segundos
	# Primeiro, verificar se o jogador está pressionando para frente e não parou
	if Input.is_action_pressed("forward") and velocity.x:
		
		# Aumentar o tempo que o jogador está andando/correndo
		running_time += delta # delta conta em segundos
		
	# Se não isso significa que o jogador parou de correr
	else:
		
		# Retornar o running time para 0
		running_time = 0
	
	#print(running_time)

func _apply_gravity(delta):
	# Se não estiver no chão
	if not is_on_floor() and enable_gravity:
		# Se o jogador NÃO estiver em wallrun
		if not wallrunning:
			# Adiconar gravidade normalmente
			velocity.y -= normal_gravity * delta
		else:
			# Adicionar gravidade de wallrun
			velocity.y -= wallrun_gravity * delta

func _auto_running():
	# Verificar se o tempo de correr passou dos triggers
	if (running_time > trigger_faster_run):
		current_speed = faster_run_speed
		
	elif (running_time > trigger_run):
		current_speed = run_speed
		
	else:
		current_speed = walk_speed

func _dash_input():
	
	# Caso jogador pressione dash e tempo de corrida for menor que o trigger de corrida
	var dash_input = Input.is_action_just_pressed("dash")
	if dash_input and running_time < trigger_run and is_on_floor():
		# Quando o jogador apertar, o running time
		# Irá direto para o trigger de correr, fa-
		# zendo o jogador correr instantaneamente
		running_time = trigger_run

func _headbob(time):
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func _change_fov(delta):
	# Limitar o valor de velocidade para realizar o calculo
	var velocity_clamp = clamp(velocity.length(), 0.5, faster_run_speed * 3)
	
	# Calcular o FOV a ser colocado
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamp
	
	# Suavizar a mudança do FOV com o lerp
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

func _vault_move(delta):
		# Caso a posição do vault seja nulo
		if vault_last_pos == null:
			# Parar o vault
			vaulting = false
			return
		
		## Movimentar suavemente
		# Fazer um calculo para o lerp
		t_target += 0.3 * delta
		
		# Realizar o lerp, movimentar suavemente entre dois pontos
		global_position = global_position.lerp(vault_last_pos, t_target)
		
		# Manter desabilitado a colisão e a gravidade para evitar travadas
		$PlayerCollider.disabled = true
		enable_gravity = false
		
		# TODO - NO PONTO QUE PARAR, O LERP DEVE PARAR DE FUNCIONAR E VOLTAR AO NORMAL
		
		# Pegar a distancia entre o jogador e o ultimo ponto do vault
		var distance_to_vault_target = (global_position - vault_last_pos).length()
		
		# Se a distancia entre o jogador e o ponto for pequena
		if (distance_to_vault_target <= 0.30):
			
			# Desabilitar o movimento de vault
			vaulting = false
			
			# Habilitar de volta a gravidade
			enable_gravity = true
			
			# Habilitar a colisão do jogador com outros objetos
			$PlayerCollider.disabled = false
			
			# Resetar calculo de suavização
			t_target = 0

func _climb_move(delta):
	# Sair desse método caso não esteja escalando
	if (climb_target_pos == null):
		return
	
	## Movimentar suavemente até o ponto
	# Calculo para a suavização
	t_target += 0.3 * delta
	
	# Realizar o lerp até a posição do climb
	global_position = global_position.lerp(climb_target_pos, t_target)
	
	# Manter desabilitado a colisão e a gravidade para evitar travadas
	$PlayerCollider.disabled = true
	enable_gravity = false
	
	# Pegar a distancia entre o jogador e o ponto alvo do climb
	var distance_to_vault_target = (global_position - climb_target_pos).length()
	
	# Se a distancia entre o jogador e o ponto for pequena
	if (distance_to_vault_target <= 0.30):
		## DESABILITAR O CLIMB
		# Desabilitar o movimento de climb
		climbing = false
		
		# Habilitar de volta a gravidade
		enable_gravity = true
		
		# Habilitar a colisão do jogador com outros objetos
		$PlayerCollider.disabled = false
		
		# Resetar calculo de suavização
		t_target = 0
		
		# Definir velocidade vertical do jogador em 0 para evitar pulos involuntários
		velocity.y = 0

func _player_move(delta):
	## Movimentos de parkour acontecem em prioridade, caso o jogador não esteja
	## em nenhum movimento de parkour, será feito o movimento normal
	
	# Desativar movimento caso o jogador esteja em wallrun
	if (wallrunning):
		return

	## MOVIMENTOS DE PARKOUR
	# Se o jogador estiver em vault
	if (vaulting):
		# Realizar movimento vault
		_vault_move(delta)
		
		# Terminar a função antes, para evitar o jogador de andar enquanto realiza o vault
		return
	
	# Se o jogador estiver em climb
	if (climbing):
		
		# Realizar movimento climb
		_climb_move(delta)
		
		# Terminar função antes
		return
	
	
	## MOVIMENTOS NORMAIS
	# Se jogador estiver no chão
	if is_on_floor():
		
		# Caso o jogador esteja se movendo
		if direction:
			
			# Ajustar a velocidade do jogador para a velocidade 
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			# Caso o contrário, o jogador terá a velocidade zerada
			velocity.x = 0
			velocity.z = 0
	
	else:
		# Se o jogador estiver no ar, o movimento vai ter mais inercia
		velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 1.5)
		velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 1.5)

func _slower_speed_moves(maximum_trigger, multiplier, stop_y_axis=false):
	## Verificar se a velocidade do jogador ta alta demais, de acordo com
	## o trigger máximo
	
	# EIXO X
	if (abs(velocity.x) > maximum_trigger):
		# Multiplicar a velocidade e diminuir
		velocity.x *= multiplier
	
	# EIXO Z
	if (abs(velocity.z) > maximum_trigger):
		# Multiplicar a velocidade e diminuit
		velocity.z *= multiplier
	
	# EIXO Y
	if (stop_y_axis):
		velocity.y *= multiplier

func _up_movement_input():
	## Evitar o botão caso já esteja realizando ações
	# VAULT
	if (vaulting):
		# Retornar pra evitar um pulo enquanto realiza o vault
		return
	
	## Realizar movimentos
	# Caso o pressione o botão de ações pra cima
	if Input.is_action_just_pressed("up_movement"):
		
		# Se estiver em wallrun
		if (wallrunning):
			
			# Sair do wallrun com pulo
			_exit_wallrun(true)

			# E assim, retornar
			return

		# Verificar raycasts
		var vault = vaultRaycast._get_raycast_collision()
		var climb = climbRaycast._get_raycast_collision()

		# Verificar um raycast para ver se tem uma parede atrás do jogador
		var backwardsClimb = backwardRaycast._check_raycast_collision()
		
		# Se o player estiver no chão
		var on_floor = is_on_floor()
		
		# Algumas ações para cima só serão ativadas quando o jogador estiver
		# Pressionando up_movement enquanto anda para frente, esse método evita
		# movimentos não desejados.
		var forward = Input.is_action_pressed("forward")
		
		## Fazer verificações
		# Se estiver no chão
		if (on_floor):
			# Se estiver andando para frente
			if (forward):
				
				# Para realizar vault
				if (vault and not climb):
					
					# Iniciar vault
					vaulting = true
					
					# Definir uma posição que o jogador terminará o vault
					vault_last_pos = vaultPositioner._get_new_vault_pos()
					
					# Diminuir a velocidade se o jogador tiver muito rapido
					_slower_speed_moves(6, 0.5)
					
					# Evitar que um pulo normal seja dado
					return
		# Se estiver no ar
		else:
			# Se estiver com uma parede ATRÁS do jogador
			if (backwardsClimb and Input.is_action_pressed("forward")):
				
				# Adicionar velocidade na direção que o jogador está vendo
				velocity.x = direction.x * wallclimb_horizontal_force
				velocity.z = direction.z * wallclimb_horizontal_force
				
				# Adicionar velocidade na vertical
				velocity.y = wallclimb_vertical_force
				
				return
				
			# Se estiver com uma parede na frente
			if (climb):
				
				# Pegar o ponto da parede
				var wall_point = climbRaycast._get_raycast_collision_point()
				
				# Calcular distancia entre o jogador e a parede
				var wall_distance_to_player = (position - wall_point).length()
				
				# Distancia entre a parede e o jogador máxima
				var wallclimb_trigger_distance = 1.60
				
				# DEBUG - TODO
				print("CLIMBING")
				print(wall_distance_to_player)
				
				# Se a distancia entre a parede e o jogador for menor que a
				# distância necessária para o trigger
				if (wall_distance_to_player <= wallclimb_trigger_distance):
					
					# TODO subir
					velocity.y = 10
				return
		
		# Iniciar um pulo normal, caso nenhuma outra condição seja satisfeita 
		# anteriormente, como wallrun, climb e vault, aumentando a velocidade de Y
		velocity.y = jump_velocity

func _air_climb_edges():
	## VARIÁVEIS
	var top_climb_edge
	var low_climb_edge

	# Caso tenha feito wallrun recentemente
	if (not _check_post_wallrun_cooldown()):
		return
	
	## DETECTAR POSSÍVEIS PAREDES AGARRÁVEIS
	# Se o jogador não estiver no ar
	if not is_on_floor():
		# Detectar se há paredes agarráveis na frente do jogador
		top_climb_edge = airClimb._dettect_walls("top")
		low_climb_edge = airClimb._dettect_walls("low")
	else:
		return
	
	## FAZER ALGO DE ACORDO COM O QUE FOI DETECTADO
	# Ter certeza de que nenhum outro movimento esteja acontecendo para evitar bugs
	if (not climbing and not wallrunning and not vaulting):
		# String da região que será usada
		var region_climb
		
		## VERIFICAÇÕES DE CADA REGIAO
		if (low_climb_edge):
			region_climb = "low"
		elif (top_climb_edge):
			region_climb = "top"
		
		# Retornar caso não tenha nenhum trigger ou o jogador não esteja andando para frente
		if (region_climb == null or not Input.is_action_pressed("forward")):
			return
		
		## INICIAR PROCESSO PARA PEGAR O PONTO DESTINO DE ESCALADA
		# Definir que o jogador está escalando
		climbing = true
		
		## DIMINUIR A VELOCIDADE DO JOGADOR PARA EVITAR BUGS
		_slower_speed_moves(6, 0.4, true)
		
		## PEGAR O PONTO OBJETIVO PARA O JOGADOR IR
		# Definir a posição do objetivo
		climb_target_pos = airClimb._get_new_climb_pos(region_climb)

func _fast_turn(delta):
	## PRIMEIRO DE TUDO, VERIFICAR SE OUTRAS AÇÕES ESTÃO SENDO REALIZADAS
	# Se o jogador já estiver virando
	if turning:
		# Realizar rotação de forma mais suave
		head.rotation.y = lerp_angle(head.rotation.y, target_head_rotation, 0.4)

		# Calcular quanto tempo o jogador está virando
		turning_time += delta

		# Parar a rotação
		if turning_time >= 0.28:

			# Desativar o estado de girando
			turning = false

			# Anular as rotações
			initial_head_rotation = null
			target_head_rotation = null

			# Permitir o jogador que olhe novamente
			can_look = true
		return

	# o jogador não pode virar enquanto realiza vault
	if vaulting or climbing:
		return
	
	# Se o jogador pressionar o botão de virar
	if Input.is_action_just_pressed("fast_turn"):

		# Habilitar o estado de rotação
		turning = true

		# Guardar rotação do jogador
		initial_head_rotation = head.rotation.y

		# Definir o ponto alvo para o jogador girar
		target_head_rotation = initial_head_rotation + deg_to_rad(180)

		# Resetar a corrida do jogador
		running_time = 0

		# Impedir o jogador de poder olhar em volta
		can_look = false

		# Contar quanto tempo o jogador está virando
		turning_time = 0

func _wallrun_move():
	# Se não está em wallrun
	if (not wallrunning):
		# Não continuar
		return
	
	# Se não estiver numa parede, se encostou no chão, ou estiver caindo muito rápido
	if (not is_on_wall() or is_on_floor() or velocity.y <= wallrun_min_vertical_velocity):
		
		# Sair do wallrun sem pulo
		_exit_wallrun(false)

		# Sair sem continuar
		return

	# Se está, executar wallrun	
	wallrun_wall_normal = get_slide_collision(0)
	
	if (wallrun_wall_normal == null):
		return
	
	## ISSO DEU CERTO SUA ANTA AGORA MELHORA ISSO
	direction = -wallrun_wall_normal.get_normal() * 7

func _wallrun_trigger():
	## Impedir o wallrun de acontecer
	# Se já estiver em wallrun
	if (wallrunning):
		return

	# Se estiver no chão
	if (is_on_floor()):
		return

	# Se estiver caindo ou não estiver subindo rapidamente
	if (velocity.y <= 0):
		return
	
	# Velocidade não pode ser muito baixa
	if (abs(velocity.x) + abs(velocity.z) <= 2):
		return

	## Direita
	if (wallrun_right.check_raycast_collision()):
		
		# Se não tinha detectado parede antes
		if (wallrun_last_wall_distance == null):

			# Definir a distancia entre o jogador e a parede
			# Isso é para ter certeza se o jogador está se aproximando da parede ou não
			wallrun_last_wall_distance = wallrun_right._get_collision_distance()

			# Retornar para impedir que continue
			return
		
		# Se já detectou paredes antes
		if (wallrun_last_wall_distance > wallrun_right._get_collision_distance()):

			## INICIAR WALLRUN
			print("Wallrun triggered")
			_start_wallrun("right")

			# Resetar ultima distancia para parede
			wallrun_last_wall_distance = null

			return
		else:
			# Cancelar wallrun
			wallrun_last_wall_distance = null

			print("Wallrun Cancelado")

			return


	## Esquerda
	if (wallrun_left.check_raycast_collision()):
		
		# Se não tinha detectado parede antes
		if (wallrun_last_wall_distance == null):

			# Definir a distancia entre o jogador e a parede
			# Isso é para ter certeza se o jogador está se aproximando da parede ou não
			wallrun_last_wall_distance = wallrun_left._get_collision_distance()

			# Retornar para impedir que continue
			return
		
		# Se já detectou paredes antes
		if (wallrun_last_wall_distance > wallrun_left._get_collision_distance()):

			## INICIAR WALLRUN
			print("Wallrun triggered")
			_start_wallrun("left")

			# Resetar ultima distancia para parede
			wallrun_last_wall_distance = null

			return
		else:
			# Cancelar wallrun
			wallrun_last_wall_distance = null

			print("Wallrun Cancelado")

			return

func _start_wallrun(wall_direction : String):
	# Ativando wallrun
	wallrunning = true

	# Indicando a direção
	wallrun_wall_direction = wall_direction

	# Definir velocidade vertical do wallrun
	velocity.y = 4

func _exit_wallrun(jumping : bool):
	# Desligar Wallrun
	wallrunning = false

	# Se não for pulando
	if (not jumping):
		return
	
	# Se for pulando
	print("Saindo wallrun")
	
	# Guardar a velocidade anterior para adicionar depois
	var stored_velocity = velocity;

	# Acelerar velocidade horizontal
	stored_velocity *= 1.2

	# Definir o impulso para o lado de acordo com o lado que a parede está
	match (wallrun_wall_direction):
		"right":
			velocity = -(camera.global_transform.basis.x * wallrun_horizontal_force)
		"left":
			velocity = camera.global_transform.basis.x * wallrun_horizontal_force
	
	# Adicionar impulso da inercia ao sair do wallrun
	velocity.x += stored_velocity.x
	velocity.z += stored_velocity.z

	# Adicionar velocidade vertical
	velocity.y = wallrun_vertical_force

	# Por fim, deixar nulo alguns detalhes
	wallrun_wall_normal = null
	wallrun_wall_direction = null

	# Iniciar cooldown para evitar bugs na parede
	post_wallrun_cooldown_current = 0	

func _tilt_head():
	# Se estiver em wallrun
	if (wallrunning):
		
		# Guardar angulo
		var tilt
		
		# Definir qual direção está a parede
		match (wallrun_wall_direction):
			"right":
				tilt = wallrun_head_tilt
			
			"left":
				tilt = -wallrun_head_tilt

		# Rotacionar cabeça
		head.rotation.z = lerp_angle(head.rotation.z, tilt, 0.2)
		
		# Impedir de continuar
		return
	
	# Se nada disso estiver conforme
	head.rotation.z = lerp_angle(head.rotation.z, 0, 0.2)

func _post_wallrun_cooldown_add(delta):
	# Se o cooldown pós wallrun eatá abaixo do maximo
	if (post_wallrun_cooldown_current < post_wallrun_cooldown):
		# Adicionar tempo
		post_wallrun_cooldown_current += delta

		print(post_wallrun_cooldown_current)

func _check_post_wallrun_cooldown():
	return post_wallrun_cooldown_current >= post_wallrun_cooldown

## PARA FISICA DO JOGO
func _physics_process(delta):
	
	# Aplicar gravidade ao jogador
	_apply_gravity(delta)

	# Verificações Wallrun
	_wallrun_trigger()

	# Realizar movimento de Wallrun caso esteja em wallrun
	_wallrun_move()

	# Movimentar a cabeça caso esteja em wallrun
	_tilt_head()

	# Cooldown para realizar outros movimentos depois de sair de um wallrun
	_post_wallrun_cooldown_add(delta)

	# Verificar se o jogador pressionou o botão de movimentos para cima
	_up_movement_input()
	
	# Verifica se o jogador está em um canto de obstaculo, para poder se agarrar
	# assim, para poder subir ou descer
	_air_climb_edges()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Calcular a corrida automatica
	_calculate_auto_running(delta)

	# Após calcular, aplicar a corrida automática
	_auto_running()
	
	# Aplicar o dash
	_dash_input()
	
	# Calcular o movimento
	_player_move(delta)
	
	# Verifica se o jogador apertou a tecla para virar rapidamente
	_fast_turn(delta)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	_change_fov(delta)
	
	move_and_slide()
