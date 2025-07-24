extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var is_dead = false
var attack_state = false
var hp = 100
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

signal player_died


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
		elif Input.is_action_just_pressed("idle"):
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
		
func start(pos):
	position = pos


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		attack_state = false
