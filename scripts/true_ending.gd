extends Control
@onready var restart_button: Button = $Panel/RestartButton
@onready var button_clicked: AudioStreamPlayer = $ButtonClicked


func _ready() -> void:
	BgmManager.play_bgm("res://assets/sounds/true_ending.mp3")
	restart_button.pressed.connect(restart_button_pressed)

func _process(delta: float) -> void:
	pass

func restart_button_pressed():
	button_clicked.play()
	await get_tree().create_timer(0.6).timeout
	print("버튼 클릭됨")
	get_tree().change_scene_to_file("res://scenes/title.tscn")
