extends Control
@onready var start_button: Button = $TextureRect/Panel2/StartButton
@onready var button_clicked: AudioStreamPlayer = $TextureRect/ButtonClicked
@onready var minimap: Control = $"../Minimap"
@onready var hp_box: Control = $"../HpBox"
@onready var title_bgm: AudioStreamPlayer = $TitleBGM


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title_bgm.play()
	visible = true
	hp_box.visible = false
	minimap.visible = false
	start_button.pressed.connect(loading_game)

func loading_game():
	button_clicked.play()
	print("start 버튼 클릭됨")
	var timer = Timer.new()
	timer.wait_time=1.5
	timer.autostart = true
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(on_start_button_pressed)

func on_start_button_pressed():
	visible = false
	hp_box.visible = true
	minimap.visible = true
	title_bgm.stop()

func _process(delta: float) -> void:
	pass
