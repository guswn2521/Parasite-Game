extends Node2D

var direction = 1
const SPEED = 60

@onready var player: CharacterBody2D = $"../../player"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += direction * SPEED * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	player.hp = 0
	player.is_dead = true
	
