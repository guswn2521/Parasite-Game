extends CanvasLayer
@onready var dna_label: Label = $DNALabel
@onready var player_numbers: Label = $PlayerNumbers
#@onready var duplication: Button = $Duplication
@onready var duplication: MenuButton = $Control/duplication

var flash_on = false
var max_flash = 3
var flash_count = 0
var is_flashing = false

func _ready() -> void:
	var cnt_dna = int(GameManager.dna)
	var player_cnt = GameManager.player_nums
	dna_label.text = "DNA 개수 : %d " % cnt_dna
	player_numbers.text = "모체 수 : %d" % player_cnt
	GameManager.connect("dna_changed", Callable(self, "_on_dna_changed"))
	GameManager.connect("player_nums_changed", Callable(self, "_on_player_nums_changed"))
	duplication.connect("no_duplication", Callable(self, "_on_no_duplication"))

func flash_timer_on(label):
	if is_flashing:
		return
	
	is_flashing = true
	var flash_timer = Timer.new()
	flash_timer.name = "flash_timer"
	flash_timer.autostart = true
	flash_timer.one_shot = false
	flash_timer.wait_time = 0.5
	add_child(flash_timer)
	flash_timer.timeout.connect(Callable(self, "on_flash_timer_timeout").bind(label))

func on_flash_timer_timeout(label):
	flash_on = !flash_on
	if flash_on:
		label.add_theme_color_override("font_color", Color(1, 1, 0, 1.0)) # 노랑
		flash_count += 1
	else:
		label.add_theme_color_override("font_color", Color(1, 1, 0, 0.4)) # 노랑,투명

	# 3번만 깜빡임
	if flash_count > max_flash:
		flash_count = 0
		flash_on = false
		is_flashing = false
		get_node("flash_timer").stop()
		get_node("flash_timer").queue_free()
		# 색깔 원상복구
		label.add_theme_color_override("font_color", Color(1,1,1))

func _on_dna_changed(new_dna):
	dna_label.text = "DNA 개수 : %d " % new_dna
	
func _on_player_nums_changed(player_nums: int) -> void:
	player_numbers.text = "모체 수 : %d" % player_nums

func _on_no_duplication():
	if GameManager.player_nums > 4:
		print("이미 5마리.")
		flash_timer_on(player_numbers)
	elif int(GameManager.dna) == 0:
		print("dna 가 0개")
		flash_timer_on(dna_label)
	
