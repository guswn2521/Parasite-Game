extends CharacterBody2D

var direction = 1
var SPEED = 80
var gravity = 300

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight

func _ready() -> void:
	add_to_group("Monsters")

func _physics_process(delta: float) -> void:
	# Default Velocity
	velocity.x = direction * SPEED
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Flip monster
	if ray_cast_left.is_colliding():
		flip_player()
		
	if ray_cast_right.is_colliding():
		print("콜라이딩")
		flip_player()
	
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
