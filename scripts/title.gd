extends Control
@onready var start_button: Button = $TextureRect/Panel2/StartButton
@onready var button_clicked: AudioStreamPlayer = $TextureRect/ButtonClicked
@onready var camera_2d: Camera2D = %Camera2D


func _ready() -> void:
	start_button.pressed.connect(loading_game)

func loading_game():
	button_clicked.play()
	await get_tree().create_timer(0.6).timeout
	get_tree().change_scene_to_file("res://scenes/loading.tscn")

func _process(delta: float) -> void:
	pass
