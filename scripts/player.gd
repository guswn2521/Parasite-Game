extends CharacterBody2D

class_name Player

@export var maxHP = 500

var player_count = GameManager.player_nums

@export var SPEED = 200.0
const JUMP_VELOCITY = -400.0
const FIRE_SCENE = preload("res://scenes/firebreath.tscn")
const FIRE_OFFSET: Vector2 = Vector2(80, 10)
const FIREBALL_SCENE = preload("res://scenes/fireball.tscn")
const FIREBALL_OFFSET: Vector2 = Vector2(8, 32)

var is_hurt = false
var is_dead = false
var walking = false
var knockback_velocity = Vector2.ZERO
var knockback_power = 200 # 원하는 값으로 조정
var attack_state = false
var facing_right := true  # 오른쪽을 보는 상태라면 true, 왼쪽이면 false
var recover_timer: Timer
var state = "base_player"
var character: AnimatedSprite2D = null
var already_in_boss_zone: bool = false

@onready var player_dot: Sprite2D = $PlayerDot
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon
@onready var evolved_animated_sprite: AnimatedSprite2D = $EvolvedAnimatedSprite
@onready var evolved_player_collision: CollisionPolygon2D = $EvolvedPlayerCollision

@onready var hurt_timer: Timer = $HurtTimer
@onready var attack_timer: Timer = $AttackTimer

@onready var player_hp: TextureProgressBar = $"../../UI/HpBox/PlayerHP"
@onready var evolution: MenuButton = $"../../UI/Control/Evolution"

@onready var jump_sfx: AudioStreamPlayer = $JumpSFX
@onready var hurt_sfx: AudioStreamPlayer = $HurtSFX
@onready var dead_sfx: AudioStreamPlayer = $DeadSFX
@onready var attack_sfx: AudioStreamPlayer = $AttackSFX
@onready var boss_tile: AnimationPlayer = $"../../Tiles/AnimationPlayer"
@onready var tiles: Node2D = $"../../Tiles"

signal player_died
signal in_boss_zone
signal out_boss_zone

func _ready() -> void:
	player_dot.visible = true
	attack_timer.timeout.connect(_on_attack_timeout)
	evolution.evolved.connect(evolved)
	evolved_animated_sprite.visible = false
	evolved_player_collision.visible = false
	evolved_player_collision.disabled = true
	add_to_group("Players")
	#currentHPs += maxHP * (player_count - 1)
	# 복제시 실행.
	#GameManager.player_nums_changed.connect(on_duplication_player_hp_change)
	#var players_node = get_parent()
	#for child in players_node.get_children():
		#if child is Player:
	#currentHPs += maxHP
	
	#print("currentHPs = ", currentHPs)
	#print("player_count = ", player_count)
	
	#player_hp.max_value = maxHP*player_count
	#player_hp.value = currentHPs
	#currentHP = currentHPs
	#recover_timer_on()
	
	# visibility layer 조절 (미니맵에 보이게 하기 위해)
	if state == "base_player":
		character = animated_sprite
		character.set_visibility_layer_bit(0, false) # 1번 Visibility Layer 끄기
		character.set_visibility_layer_bit(2, true) # 3번 Visibility Layer 켜기
	player_dot.set_visibility_layer_bit(0,false) # 1번 끄기
	player_dot.set_visibility_layer_bit(1,true) #2번 켜기
		

func evolved():
	maxHP = 3000
	state = "evolved"
	animated_sprite.visible = false
	evolved_animated_sprite.visible = true
	evolved_player_collision.visible = true
	evolved_player_collision.disabled = false
	collision_polygon.visible = false
	collision_polygon.disabled = true
	
	if state == "evolved":
		character = evolved_animated_sprite
		character.set_visibility_layer_bit(0, false) # 1번 Visibility Layer 끄기
		character.set_visibility_layer_bit(2, true) # 3번 Visibility Layer 켜기

func fire_ball() -> void:
	var fireball_instance = FIREBALL_SCENE.instantiate()
	attack_sfx.play()
	get_tree().get_nodes_in_group("Fireballs").front().add_child(fireball_instance)
	fireball_instance.global_position = global_position + FIREBALL_OFFSET
	print("fireball ", FIREBALL_OFFSET)
	fireball_instance.start_position = fireball_instance.global_position  # 사거리 비교용 초기값 지정
	fireball_instance.set_left(character.flip_h)

func fire_breath() -> void:
	var fire_instance = FIRE_SCENE.instantiate()
	get_tree().get_nodes_in_group("Fireballs").front().add_child(fire_instance)
	fire_instance.global_position = global_position + FIRE_OFFSET
	fire_instance.set_left(evolved_animated_sprite.flip_h)
	await get_tree().create_timer(0.45).timeout
	fire_instance.queue_free()
	attack_state=false

func player_collision_shape_fliph(facing_left: bool, collision_shape):
	if facing_left:
		collision_shape.scale.x = abs(collision_shape.scale.x) * -1
		#collision_shape.position = collision_shape.facing_left_position
	else:
		collision_shape.scale.x = abs(collision_shape.scale.x) * 1
		#collision_shape.position = collision_shape.facing_right_position

func _physics_process(delta: float) -> void:
	#if is_dead:
		#return
	
	if !already_in_boss_zone and position.x >= 63900:
		already_in_boss_zone = true
		print("보스존 입성")
		emit_signal("in_boss_zone")
		tiles.block_boss_zone()
		
	if already_in_boss_zone and position.x < 63900:
		already_in_boss_zone = false
		print("보스존 나감")
		emit_signal("out_boss_zone")
	
	if is_hurt:
		position += knockback_velocity * delta
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500 * delta)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 1.5

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()

	# Get the input direction 1, 0, -1
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip the sprite
	if not is_dead:
		if direction == -1:
			character.flip_h = true
		elif direction == 1:
			character.flip_h = false

	if state == "base_player":
		player_collision_shape_fliph(animated_sprite.flip_h, collision_polygon) 
		
	elif state == "evolved":
		player_collision_shape_fliph(evolved_animated_sprite.flip_h, evolved_player_collision)
	
	# Apply Movement
	if direction:
		walking = true
		velocity.x = direction * SPEED
	else:
		walking = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
	# Play Animations
	if Input.is_action_just_pressed("attack") and not attack_state:
		attack_timer.start()
		character.play("attack")
		if character == animated_sprite:
			fire_ball()
		elif character == evolved_animated_sprite:
			fire_breath()
		attack_state=true
	if attack_state:
		return
	if is_hurt:
		return
	if is_dead:
		velocity.x = 0
		if character.animation != "death":
			emit_signal("player_died")
			character.play("death")
	elif is_on_floor():
		if not Input.is_anything_pressed() and direction == 0:
			character.play("idle")
		else:
			character.play("walk")
		
func start(pos):
	position = pos

func _on_attack_timeout() -> void:
	print("player attack timer fin")
	attack_state = false
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if character.animation == "death":
		print("player death fin")

func take_damage(direction:int, amount: int) -> void:
	if is_dead:
		return
	amount = int(amount/player_count)
	GameManager.currentHPs -= amount
	#player_hp.value -= amount
	#player_hp_points.text = "%d/%d" % [player_hp.value,player_hp.max_value]
	#print("player current HP: ", player_hp.value)
	if GameManager.currentHPs <= 0:
		hurt_sfx.play()
		await get_tree().create_timer(0.5).timeout
		dead_sfx.play()
		death_motion()
		emit_signal("player_died")
	else:
		hurt_motion(direction)

func hurt_motion(direction: int) -> void:
	is_hurt = true
	character.play("hurt")
	hurt_sfx.play()
	print("**********")
	knockback_velocity = Vector2(direction,0) * knockback_power
	hurt_timer.start(0.4)
	
func _on_hurt_timer_timeout() -> void:
	print("player hurt timer fin")
	if not is_dead:
		is_hurt = false
		knockback_velocity = Vector2.ZERO
	
func death_motion() -> void:
	#print("player death")
	character.play("death")
	is_dead = true
	SPEED = 0
