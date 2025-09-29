extends CanvasLayer
#@onready var duplication: Button = $Duplication
@onready var duplication: MenuButton = $Control/duplication
@onready var evolution: MenuButton = $Control/Evolution
@onready var dna_label: Label = $Labels/DNALabel
@onready var player_numbers: Label = $Labels/PlayerNumbers
@onready var failed_sfx: AudioStreamPlayer = $Control/FailedSFX
@onready var boss_hp_box: Control = $BossHpBox
@onready var player: Player = %player
@onready var boss_zone_bgm: AudioStreamPlayer = $BossHpBox/BossZoneBGM
@onready var player_hp_points: Label = $HpBox/PlayerHP/PlayerHPPoints
@onready var player_hp: TextureProgressBar = $HpBox/PlayerHP

var flash_on = false
var max_flash = 3
var flash_count = 0
var is_flashing = false


func _ready() -> void:
	boss_hp_box.visible = false
	var player_cnt = GameManager.player_nums
	var cnt_dna = int(GameManager.dna)
	dna_label.text = "DNA 개수 : %d " % cnt_dna
	player_numbers.text = "모체 수 : %d" % player_cnt
	GameManager.dna_changed.connect(_on_dna_changed)
	GameManager.player_nums_changed.connect(_on_player_nums_changed)
	duplication.no_duplication.connect(_on_no_duplication)
	evolution.no_evolution.connect(_on_no_evolution)
	player.in_boss_zone.connect(boss_energy_bar)
	player.out_boss_zone.connect(no_boss_energy_bar)
	GameManager.player_hp_changed.connect(on_player_hp_changed)
	
func on_player_hp_changed(hp):
	var max_hp_value = player.maxHP * GameManager.player_nums
	print("=====================")
	print(hp)
	print(GameManager.player_nums)
	player_hp_points.text = "%d/%d" % [hp, max_hp_value]
	player_hp.max_value = max_hp_value
	player_hp.value = hp

func no_boss_energy_bar():
	boss_hp_box.visible = false
	BgmManager.play_bgm_list()
func boss_energy_bar():
	boss_hp_box.visible = true
	BgmManager.play_bgm("res://assets/sounds/boss_bgm.mp3")

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
	#flash_timer.timeout.connect(on_flash_timer_timeout(label))
	

func on_flash_timer_timeout(label):
	flash_on = !flash_on
	if flash_on:
		label.add_theme_color_override("font_color", Color(1, 1, 0, 1.0)) # 노랑
		flash_count += 1
		failed_sfx.play()
	else:
		label.add_theme_color_override("font_color", Color(1, 1, 0, 0.4)) # 노랑,투명

	# 3번만 깜빡임
	if flash_count > max_flash:
		flash_on = false
		is_flashing = false
		flash_count = 0
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

func _on_no_evolution():
	flash_timer_on(player_numbers)
