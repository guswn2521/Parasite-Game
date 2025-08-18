extends CharacterBody2D

class_name Player

var SPEED = 200.0
const JUMP_VELOCITY = -400.0
var is_hurt = false
var is_dead = false
var hurt_duration = 0.5 # 애니메이션 길이에 맞춰서 수정
var knockback_velocity = Vector2.ZERO
var knockback_power = 200 # 원하는 값으로 조정
var maxHP = 100
var recover_amount = 2
var attack_state = false
const FIREBALL_SCENE = preload("res://scenes/fireball.tscn")
const FIREBALL_OFFSET: Vector2 = Vector2(0.0, 0.0)
var facing_right := true  # 오른쪽을 보는 상태라면 true, 왼쪽이면 false
var recover_timer: Timer
var ending_position = 64301
@export var face_collision_shape: FaceCollisionShape
@export var body_collision_shape : BodyCollisionShape
@export var tail_collision_shape : TailCollisionShape

@onready var currentHP: int = maxHP
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_timer: Timer = $HurtTimer
#@onready var player_hp: TextureProgressBar = $"../../UI/PlayerHP"
#@onready var player_hp_points: Label = $"../../UI/PlayerHP/PlayerHPPoints"
@onready var player_hp: TextureProgressBar = $"../../UI/HpBox/Panel/PlayerHP"
@onready var player_hp_points: Label = $"../../UI/HpBox/Panel/PlayerHP/PlayerHPPoints"

signal player_died
signal player_arrived

func _ready() -> void:
	add_to_group("Players")
	var players_node = get_node("/root/Game/Players")  # 또는 상대경로 $Players 등 사용
	var currentHPs = 0
	var player_count = 0
	# player 노드가 CharacterBody2D 클래스일 경우 체크 할 수 있음
	for child in players_node.get_children():
		if child is Player:
			currentHPs += child.currentHP
			player_count += 1
	
	player_hp.max_value = maxHP*player_count
	player_hp.value = currentHPs
	player_hp_points.text = "%d/%d" % [player_hp.value,player_hp.max_value]
	recover_timer_on()

func recover_timer_on():
	recover_timer = Timer.new()
	recover_timer.autostart = true
	recover_timer.one_shot = false
	recover_timer.wait_time = 1.0
	add_child(recover_timer)
	recover_timer.timeout.connect(Callable(self, "recover_timer_timeout"))
	recover_timer.start()

func recover_timer_timeout():
	if currentHP < maxHP:
		currentHP += recover_amount
		currentHP = min(currentHP, maxHP)
		player_hp.value = currentHP
		player_hp_points.text = "%d/%d" % [player_hp.value,player_hp.max_value]
		print("HP 회복! 현재 HP:", currentHP)

func fire_ball() -> void:
	var fireball_instance = FIREBALL_SCENE.instantiate()
	get_tree().get_nodes_in_group("Fireballs").front().add_child(fireball_instance)
	fireball_instance.global_position = global_position + FIREBALL_OFFSET
	fireball_instance.set_left(animated_sprite.flip_h)

func player_collision_shape_fliph(facing_left: bool):
	if facing_left:
		face_collision_shape.position = face_collision_shape.facing_left_position
		body_collision_shape.position = body_collision_shape.facing_left_position
		tail_collision_shape.position = tail_collision_shape.facing_left_position
		tail_collision_shape.rotation_degrees = tail_collision_shape.facing_left_rotation
	else:
		face_collision_shape.position = face_collision_shape.facing_right_position
		body_collision_shape.position = body_collision_shape.facing_right_position
		tail_collision_shape.position = tail_collision_shape.facing_right_position
		tail_collision_shape.rotation_degrees = tail_collision_shape.facing_right_rotation

func _physics_process(delta: float) -> void:
	if position.x >= ending_position:
		emit_signal("player_arrived")
	#if is_dead:
		#return
	if is_hurt:
		position += knockback_velocity * delta
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500 * delta)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 1.5

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction 1, 0, -1
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip the sprite
	if not is_dead:
		if direction == -1:
			animated_sprite.flip_h = true
		elif direction == 1:
			animated_sprite.flip_h = false
	player_collision_shape_fliph(animated_sprite.flip_h) 
	
	# Apply Movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
	# Play Animations
	if Input.is_action_just_pressed("attack") and not attack_state:
		animated_sprite.play("attack")
		fire_ball()
		attack_state=true
	if attack_state:
		return
	if is_hurt:
		return
	if is_dead:
		velocity.x = 0
		if animated_sprite.animation != "death":
			emit_signal("player_died")
			animated_sprite.play("death")
	elif is_on_floor():
		if not Input.is_anything_pressed() and direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
		
func start(pos):
	position = pos


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		attack_state = false
	if animated_sprite.animation == "death":
		print("player death fin")

func take_damage(direction:int, amount: int) -> void:
	if is_dead:
		return
	currentHP -= amount
	player_hp.value -= amount
	player_hp_points.text = "%d/%d" % [player_hp.value,player_hp.max_value]
	print("player current HP: ", player_hp.value)
	if player_hp.value <= 0:
		death_motion()
		emit_signal("player_died")
	else:
		hurt_motion(direction)

func hurt_motion(direction: int) -> void:
	is_hurt = true
	animated_sprite.play("hurt")
	knockback_velocity = Vector2(direction,0) * knockback_power
	hurt_timer.start(0.4)
	
func _on_hurt_timer_timeout() -> void:
	if not is_dead:
		is_hurt = false
		knockback_velocity = Vector2.ZERO
	
func death_motion() -> void:
	print("player death")
	animated_sprite.play("death")
	is_dead = true
	SPEED = 0
