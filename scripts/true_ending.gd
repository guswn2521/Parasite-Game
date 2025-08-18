extends Control
@onready var restart_button: Button = $Panel/RestartButton
@onready var button_clicked: AudioStreamPlayer2D = $ButtonClicked


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	restart_button.pressed.connect(restart_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_true_ending():
	var timer = Timer.new()
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = 1.0
	add_child(timer)
	timer.timeout.connect(timer_timeout)

func timer_timeout():
	visible = true


func restart_button_pressed():
	button_clicked.play()
	get_tree().reload_current_scene()
