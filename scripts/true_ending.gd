extends Control
@onready var restart_button: Button = $Panel/RestartButton
@onready var button_clicked: AudioStreamPlayer = $ButtonClicked
@onready var true_ending_bgm: AudioStreamPlayer = $TrueEndingBGM


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#visible = false
	restart_button.pressed.connect(restart_button_pressed)

func _process(delta: float) -> void:
	pass

func show_true_ending():
	BgmManager.play_bgm("res://assets/sounds/true_ending.mp3")


func restart_button_pressed():
	button_clicked.play()
	print("버튼 클릭됨")
	get_tree().reload_current_scene()
