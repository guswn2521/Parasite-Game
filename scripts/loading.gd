extends Control
@onready var loading_dragon: AnimatedSprite2D = $TextureRect/LoadingDragon


func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _process(delta: float) -> void:
	var speed = 500
	if loading_dragon.position.x >= 1800:
		loading_dragon.position.x = 600
	loading_dragon.position.x += delta * speed
