extends CharacterBody2D

var direction = 1
var SPEED = 80
var gravity = 300
var in_chase = false
var in_attack_area = false
var can_attack: bool = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var players_parent: Node2D = $"../../Players"
@onready var chase_area: Area2D = $ChaseArea
@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer

func _ready() -> void:
	add_to_group("Monsters")
	chase_area.body_entered.connect(_on_chase_area_body_entered)
	chase_area.body_exited.connect(_on_chase_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	

func _physics_process(delta: float) -> void:
	# Flip monster
	if ray_cast_left.is_colliding():
		flip_player()
	if ray_cast_right.is_colliding():
		flip_player()
		
	# Chase
	if in_chase:
		var player = players_parent.get_children()[0]
		var distance = player.position.x - position.x
		if abs(distance) <= 10:
			velocity.x = 0
		else:
			if distance > 0:
				direction = 1
				animated_sprite.flip_h = true
			else:
				direction = -1
				animated_sprite.flip_h = false
		
	# Default Velocity
	velocity.x = direction * SPEED
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	#print(direction, SPEED)
	move_and_slide()
	
	
	# Play Animation
	animated_sprite.play("run")
	#if not on_attack:
		#animated_sprite.play("walk")
	#if is_hurt:
		#animated_sprite.visible = true
		#animated_attack_left.visible = false
		#animated_attack_right.visible = false
	#if death:
		#if animated_sprite.animation != "death":
			#animated_sprite.play("death")
			
func flip_player():
	direction *= -1
	animated_sprite.flip_h = not animated_sprite.flip_h

func _on_chase_area_body_entered(body: Node2D) -> void:
	if "player" in body.name:
		print("Mushroom chase 시작: ", body.name)
		in_chase = true
	
func _on_chase_area_body_exited(body: Node2D) -> void:
	if "player" in body.name:
		print("Mushrrom chase 끝")
		in_chase = false
		
func _on_attack_area_body_entered(body:Node2D) -> void:
	if "player" in body.name:
		in_attack_area = true
	
func _on_attack_area_body_exited(body:Node2D) -> void:
	if "player" in body.name:
		in_attack_area = false
