extends Control


func _ready() -> void:
	BgmManager.play_bgm("res://assets/sounds/game_over.mp3")
	await get_tree().create_timer(4.0).timeout
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _process(delta: float) -> void:
	pass
