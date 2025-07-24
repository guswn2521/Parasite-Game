extends Node2D

var direction = 1
const SPEED = 60

@onready var player: CharacterBody2D = $"../../player"
@onready var ray_cast_right: RayCast2D = $RayCast2D_right
@onready var ray_cast_left: RayCast2D = $RayCast2D_left
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
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
	player.hp = 0
	player.is_dead = true
	
