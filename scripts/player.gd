extends CharacterBody2D

class_name Player

const SPEED = 130.0
const JUMP_VELOCITY = -500.0
var is_hurt = false
var is_dead = false
var hurt_duration = 0.5 # 애니메이션 길이에 맞춰서 수정
var knockback_velocity = Vector2.ZERO
var knockback_power = 200 # 원하는 값으로 조정
var maxHP = 1000
var attack_state = false
const FIREBALL_SCENE = preload("res://scenes/fireball.tscn")
const FIREBALL_OFFSET: Vector2 = Vector2(0.0, 0.0)
var facing_right := true  # 오른쪽을 보는 상태라면 true, 왼쪽이면 false

@onready var currentHP: int = maxHP
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

signal player_died

func _ready() -> void:
	add_to_group("Players")
	
func fire_ball() -> void:
	var fireball_instance = FIREBALL_SCENE.instantiate()
	get_tree().get_nodes_in_group("Fireballs").front().add_child(fireball_instance)
	fireball_instance.global_position = global_position + FIREBALL_OFFSET
	fireball_instance.set_left(animated_sprite.flip_h)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

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

func hurt_effect():
	animated_sprite.play("hurt")

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("맞음")
	hurt_effect()
