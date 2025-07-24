extends Node2D

var direction = 1
var SPEED = 60
var gravity = 300
var death = false

@onready var player: CharacterBody2D = $"../../player"
@onready var ray_cast_right: RayCast2D = $RayCast2D_right
@onready var ray_cast_left: RayCast2D = $RayCast2D_left
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var ray_cast_bottom: RayCast2D = $RayCast2D_bottom

signal is_on_floor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Monsters")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not ray_cast_bottom.is_colliding():
		position.y += gravity * delta
	if death:
		return
	if ray_cast_left.is_colliding():
		print("flip to left")
		direction = -1
		animated_sprite.flip_h = false
		
	if ray_cast_right.is_colliding():
		print("flip to right")
		direction = 1
		animated_sprite.flip_h = true
		
	position.x += direction * SPEED * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player.hp = 0
		player.is_dead = true

func death_motion() -> void:
	print("death", position)
	animated_sprite.play("death")
	death = true
	SPEED = Vector2.ZERO


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
