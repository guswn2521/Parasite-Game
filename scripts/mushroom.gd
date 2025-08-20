extends CharacterBody2D

var direction = 1
var SPEED = 80
var gravity = 300
var in_chase = false
var in_attack_area = false
var on_attack = false
var can_attack: bool = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var players_parent: Node2D = $"../../Players"
@onready var chase_area: Area2D = $ChaseArea
@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer
@onready var animation_player: AnimationPlayer = $AttackAnimation
@onready var hit_box: Area2D = $HitBox

func _ready() -> void:
	add_to_group("Monsters")
	chase_area.body_entered.connect(_on_chase_area_body_entered)
	chase_area.body_exited.connect(_on_chase_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	hit_box.body_entered.connect(_on_hitbox_body_entered)
	attack_timer.timeout.connect(_on_attack_timeout)
	
func _physics_process(delta: float) -> void:
	# Flip monster
	if ray_cast_left.is_colliding():
		flip_player()
	if ray_cast_right.is_colliding():
		flip_player()
	
	# Attack
	if in_attack_area and can_attack:
		attack_animation()
		can_attack = false
		attack_timer.start()
	
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
	if not on_attack:
		animated_sprite.play("run")
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
		print("attack area body entered")
		in_attack_area = true
	
func _on_attack_area_body_exited(body:Node2D) -> void:
	if "player" in body.name:
		print("attack area body exited")
		in_attack_area = false
		
func attack_animation():
	if not can_attack:
		return
	if animated_sprite.animation == "attack":
		return
	if not animation_player.current_animation in ["attack_left","attack_right"]:
		on_attack = true
		var player = players_parent.get_children()[0]
		if position.x - player.position.x > 0:
			# 플레이어가 왼쪽에서 다가옴
			direction = -1
			animated_sprite.flip_h = false
			#animated_attack_left.visible = true
			animation_player.play("attack_left")
			animated_sprite.play("attack")
				
		elif position.x - player.position.x < 0:
			# 플레이어가 오른쪽에서 다가옴
			direction = 1
			animation_player.play("attack_right")
			#animated_attack_right.visible = true
			animated_sprite.flip_h = true
			animated_sprite.play("attack")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["attack_left","attack_right"]:
		on_attack = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		print("Mushroom Attack success")
		#body.take_damage(direction, monster_attack_damage)
func _on_attack_timeout() -> void:
	print("attack timer fin")
	can_attack = true
