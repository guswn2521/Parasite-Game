extends Node2D

@export var mob_scene: PackedScene

@onready var player: CharacterBody2D = $Players/player
@onready var evolved_player: CharacterBody2D = $Players/evolved_player
@onready var mob_timer: Timer = $Timers/MobTimer
@onready var monsters: Node = $Monsters
@onready var gameover: Control = $UI/Gameover
@onready var true_ending: Control = $UI/TrueEnding
@onready var sub_viewport: SubViewport = $SubViewport
@onready var camera_2d: Camera2D = $Players/player/Camera2D

var is_true_ending : bool = false
var true_ending_triggered : bool = false

var monsters_position = [
	Vector2(612.0, -40.0),
	Vector2(4297.0, -40.0),
	Vector2(10349.0, -40.0),
	Vector2(24273.0, 0.0),
	Vector2(32207.0, -100.0),
	Vector2(42775.0, -40.0),
	Vector2(47036.0, -40.0),
	Vector2(54923.0, -40.0),
	Vector2(59240.0, -40.0)
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
		print("몬스터 생성", mob.global_position)
		monsters.add_child(mob)

func game_over():
	mob_timer.stop()
	print("game_over")
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/gameover.tscn")

func _ready() -> void:
	BgmManager.play_bgm_list()
	get_viewport().canvas_cull_mask &= ~2  # 1번 비트 끄기
	
	if player != null:
		player.connect("player_died", Callable(self, "game_over"))
		player.player_arrived.connect(decide_true_ending)
	new_game()
	

func decide_true_ending():
	if true_ending_triggered:
		return
	print("is_true_ending = true")
	is_true_ending = true

func _process(delta: float) -> void:
	if is_true_ending and !true_ending_triggered:
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/true_ending.tscn")
		true_ending_triggered = true
		
