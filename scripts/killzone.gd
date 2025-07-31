extends Area2D

@onready var player: Player = $"../Players/player"
@onready var killzone_timer: Timer = $KillzoneTimer


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		killzone_timer.start()


func _on_killzone_timer_timeout() -> void:
	player.is_dead = true
