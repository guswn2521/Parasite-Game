extends Node2D

@export var mob_scene: PackedScene
@export var mushroom_scene: PackedScene
@export var dog_scene: PackedScene

@onready var player: CharacterBody2D = $Players/player
@onready var evolved_player: CharacterBody2D = $Players/evolved_player
@onready var mob_timer: Timer = $Timers/MobTimer
@onready var monsters: Node = $Monsters
@onready var gameover: Control = $UI/Gameover
@onready var true_ending: Control = $UI/TrueEnding
@onready var sub_viewport: SubViewport = $SubViewport
@onready var camera_2d: Camera2D = $Players/player/Camera2D
@onready var boss: CharacterBody2D = $Monsters/Boss

var is_true_ending : bool = false
var true_ending_triggered : bool = false

var monsters_position = [
	Vector2(612.0, -40.0),
	Vector2(4297.0, -40.0),
	Vector2(10349.0, -40.0),
	Vector2(14500.0, -40.0),
	Vector2(18500.0, -40.0),
	Vector2(24273.0, 0.0),
	Vector2(28500.0, -20.0),
	Vector2(32207.0, -100.0),
	Vector2(37000.0, -100.0),
	Vector2(42775.0, -40.0),
	Vector2(47036.0, -40.0),
	Vector2(54923.0, -40.0),
	Vector2(59240.0, -40.0)
]
var mushrooms_position = [
	Vector2(0, -7.0),
	Vector2(1000, -7.0),
	Vector2(2000, -7.0),
	Vector2(3000, -7.0),
	Vector2(4000, -7.0),
	Vector2(5000, -7.0),
	Vector2(6000, -7.0),
	Vector2(7000, -7.0),
	Vector2(8000, -7.0),
	Vector2(9000, -7.0),
	Vector2(10000, -7.0),
	Vector2(11000, -7.0),
	Vector2(12000, -7.0),
	Vector2(13000, -7.0),
	Vector2(14000, -7.0),
	Vector2(15000, -7.0),
	Vector2(16000, -7.0),
	Vector2(17000, -7.0),
	Vector2(18000, -7.0)
]
var dogs_position = [
	Vector2(20020,0),
	Vector2(21020, -60),
	Vector2(22020, -60),
	Vector2(22720, -150),
	Vector2(24000, 0),
	Vector2(25300, 0),
	Vector2(26000, 0),
	Vector2(27000, 0),
	Vector2(28000, -30),
	Vector2(29000, 0),
	Vector2(30000, 0),
	Vector2(31000, -30),
	Vector2(32100, -30),
	Vector2(33000, -140),
	Vector2(35000, 100),
	Vector2(36000, -20),
	Vector2(37000, -20),
	Vector2(38000, -20),
	Vector2(39000, -20)
]

func get_monster_positions():
	var positions = []
	for monster in monsters.get_children():
		positions.append(monster.global_position)
	print(positions)

func new_game():
	get_monster_positions()
	GameManager.dna = 0
	mob_timer.start()

func _on_mob_timer_timeout() -> void:
	for position in monsters_position:
		var mob = mob_scene.instantiate()
		mob.global_position = position
		monsters.add_child(mob)
	print("몬스터 생성")
	for position in mushrooms_position:
		var mob = mushroom_scene.instantiate()
		mob.global_position = position
		monsters.add_child(mob)
	print("mushroom 생성")
	for position in dogs_position:
		var mob = dog_scene.instantiate()
		mob.global_position = position
		monsters.add_child(mob)
	print("dog 생성")

func game_over():
	mob_timer.stop()
	print("game_over")
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/gameover.tscn")

func _ready() -> void:
	if player.position.x < 63700:
		BgmManager.play_bgm_list()
	get_viewport().canvas_cull_mask &= ~2  # 2번 비트 끄기
	boss.boss_died.connect(decide_true_ending)
	if player != null:
		player.player_died.connect(game_over)
		#player.connect("player_died", Callable(self, "game_over"))
	new_game()

func decide_true_ending():
	await get_tree().create_timer(2.0).timeout
	if true_ending_triggered:
		return
	print("is_true_ending = true")
	is_true_ending = true

func _process(delta: float) -> void:
	if is_true_ending and !true_ending_triggered:
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/true_ending.tscn")
		true_ending_triggered = true
		
