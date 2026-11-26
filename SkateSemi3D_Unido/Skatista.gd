extends CharacterBody2D

@onready var estrada: Node2D = $".."
@onready var skatista: Node2D = $Corpo
@onready var _skate_animation = $Corpo
@onready var character_skate = $"."

@export var crv_stg: float = 10
@export var speed: float = 150 
@export var friction: float = 4 #quanto maior, mais facil parar

var current_side: float = 0
var speed_zoom: float = 0

var is_in_curve: bool = false
var curve_side: int = 1



func _ready() -> void:
	for colider in get_tree().get_nodes_in_group("Colisores_Direita"):
		colider.body_entered.connect(_on_colisor_direita_entered.bind(colider))
		
	for colider in get_tree().get_nodes_in_group("Colisores_Esquerda"):
		colider.body_entered.connect(_on_colisor_esquerda_entered.bind(colider))
		
	for colider in get_tree().get_nodes_in_group("Colisores_Meio"):
		colider.body_entered.connect(_on_colisor_meio_entered.bind(colider))
		
	for colider in get_tree().get_nodes_in_group("Colisores_Limite"):
		colider.body_entered.connect(_on_colisor_limite_entered.bind(colider))
		
	estrada.curva.connect(_verificar_curva)
	
func _process(delta: float) -> void:
	var speed_sent = Input.get_axis("Vel_Diminuir", "Vel_Aumento")
	var drift_force: float = 1
	#aumenta o poder do freio dele, pra desacelerar
	if Input.is_action_pressed("Drift") and speed_sent < 0:
		drift_force = 10
	else:
		drift_force = 1
		
	if speed_sent != 0:
		var zoom_change = speed_sent * 0.25 * drift_force
		speed_zoom = clampf(speed_zoom + zoom_change, 0, 75) #variação do intervalo (pra n ir muito pra frente ou passar do 0)
		estrada.velocidade = clampf(estrada.velocidade + 0.005 * speed_sent * drift_force, 1.5, 15) #mesma coisa, mas pra estrada (pra ela n inverter ou afinar), ta meio desicronizado, mas quase imperceptivel
		#escalas pro boneco
		var min_scale = 0.16
		var max_scale = 0.1
		var t = speed_zoom / 100
		if t > 0.6:
			t = 0.6
		#                   | vector2 com os 2 valores no 1. Não conhecia :v
		#                   V         de novo, ta limitando a escala pra ele n crescer demais
		skatista.scale = Vector2.ONE * lerpf(max_scale, min_scale, t)
		#ajustar a posição Y do nosso querido bonequinho
		var target_y = -speed_zoom * 1.005
		if target_y < -61.3:
			target_y = -61.3
		
		skatista.position.y = lerpf(skatista.position.y, target_y, 0.1)
	
	#-------------------------------------------------------------------------------------------------------------------
	#identifica se está fanzendo a curva
	

func _verificar_curva(na_curva: bool, dir_curva: int):
	is_in_curve = na_curva
	if na_curva:
		current_side = dir_curva
		curve_side = dir_curva
	
	
	

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_axis("< GO", "GO >")
	#se ele estiver apertando pra ir pro lado, ele vai pro lado que quer
	if input_dir != 0:
		if !is_in_curve:
			velocity.x = input_dir * speed
		else:
			if input_dir == curve_side:
				velocity.x = input_dir * speed
			else:
				if Input.is_action_pressed("Drift"):
					velocity.x = (input_dir * speed / 2) - (input_dir * speed_zoom * 2)
				else:
					velocity.x = input_dir * speed / (3 * (speed/10))
	#se não, ele vai ser puxado pro lado que ele ja ta indo, direção a borda e a triste morte ;-;
	else:
		if is_in_curve:
			velocity.x = curve_side * (speed / friction) * (crv_stg * -1)
		else:
			velocity.x = current_side * (speed / friction)
	move_and_slide()

func _on_colisor_direita_entered(body: Node2D, colisor: Area2D) -> void: #Identifica pra qual lado ele vai inclinar e muda o sprite
	if body != self:
		return
	current_side = 1
	#como vai mudar os SPRITES, tem que ver se a animação fica suave depois
	if is_in_curve:
		if curve_side < 0:
			_skate_animation.play("out-dentro")
		else:
			_skate_animation.play("dentro")
	else:
		match colisor.name:
				"D_1":
					#_skate_animation.play("out-tr-21")  
					#await _skate_animation.animation_finished
					_skate_animation.play("out-lado-01")
				"D_2":
					#_skate_animation.play("out-tr-12")  
					#await _skate_animation.animation_finished
					_skate_animation.play("out-lado-02")
				"D_3", "D_4", "D_5", "D_6":
					#_skate_animation.play("out-tr-23")  
					#await _skate_animation.animation_finished
					_skate_animation.play("out-lado-03")
		




func _on_colisor_esquerda_entered(body: Node2D, colisor: Area2D) -> void: #Identifica pra qual lado ele vai inclinar e muda o sprite
	if body != self:
		return
	current_side = -1 #muda o deslize pra direita
	
	#como vai mudar os SPRITES, tem que ver se a animação fica suave depois
	if is_in_curve:
		if curve_side < 0:
			_skate_animation.play("out-fora")
		else:
			_skate_animation.play("fora")
	else:
		match colisor.name:
			"E_1":
				#_skate_animation.play("tr-12")  
				#await _skate_animation.animation_finished
				_skate_animation.play("lado-01")
			"E_2":
				#_skate_animation.play("tr-23")  
				#await _skate_animation.animation_finished
				_skate_animation.play("lado-02")
			"E_3", "E_4", "E_5", "E_6":
				#_skate_animation.play("tr-23")  
				#await _skate_animation.animation_finished
				_skate_animation.play("lado-03")
func _on_colisor_limite_entered(body: Node2D, colisor: Area2D) -> void: #Identifica pra qual lado ele vai inclinar e muda o sprite
	if body != self:
		return
func _on_colisor_meio_entered(body: Node2D, colisor: Area2D) -> void: #Identifica pra qual lado ele vai inclinar e muda o sprite
	if body != self:
		return
	if !is_in_curve:
		_skate_animation.play("default")
	else:
		if curve_side > 0:
			_skate_animation.play("meio")
		else:
			_skate_animation.play("out-meio")
