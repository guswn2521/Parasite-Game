extends Node2D

var direction = 1
var SPEED = 60
var gravity = 300
var HP = 100
var death = false
var is_hurt = false
var hurt_duration = 0.5 # 애니메이션 길이에 맞춰서 수정
var knockback_velocity = Vector2.ZERO
var knockback_power = 200 # 원하는 값으로 조정
@onready var hurt_timer: Timer = $HurtTimer

@onready var player: CharacterBody2D = $"../../player"
@onready var ray_cast_left: RayCast2D = $Area2D/RayCast2D_left
@onready var ray_cast_right: RayCast2D = $Area2D/RayCast2D_right
@onready var ray_cast_bottom: RayCast2D = $Area2D/RayCast2D_bottom

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D


signal is_on_floor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Monsters")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_hurt:
		position += knockback_velocity * delta
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500 * delta)
		
	if not ray_cast_bottom.is_colliding():
		position.y += gravity * delta
	if death:
		return
	if ray_cast_left.is_colliding():
		direction = -1
		animated_sprite.flip_h = false
		
	if ray_cast_right.is_colliding():
		direction = 1
		animated_sprite.flip_h = true
		
	position.x += direction * SPEED * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player.hp = 0
		player.is_dead = true
		
func hurt_motion(direction: int) -> void:
	print("hurt")
	is_hurt = true
	animated_sprite.play("hurt")
	knockback_velocity = Vector2(direction,0) * knockback_power
	hurt_timer.start(0.4)

func _on_hurt_timer_timeout() -> void:
	is_hurt = false
	knockback_velocity = Vector2.ZERO
	# 한 대 맞은거 끝나면 다시 걷기 실행.
	animated_sprite.play("walk")


func death_motion() -> void:
	animated_sprite.play("death")
	death = true
	SPEED = Vector2.ZERO


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "death":
		queue_free()
