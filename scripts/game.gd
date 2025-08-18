extends Node2D

@export var mob_scene: PackedScene

@onready var player: CharacterBody2D = $Players/player
@onready var evolved_player: CharacterBody2D = $Players/evolved_player
@onready var start_timer: Timer = $Timers/StartTimer
@onready var mob_timer: Timer = $Timers/MobTimer
@onready var monsters: Node = $Monsters
@onready var gameover: Control = $UI/Gameover
@onready var gameover_timer: Timer = $UI/Gameover/GameoverTimer
@onready var true_ending: Control = $UI/TrueEnding
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
	gameover.visible = false
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
	start_timer.start()
	gameover_timer.start()
	

func _on_gameover_timer_timeout() -> void:
	gameover.visible = true

func _on_start_timer_timeout() -> void:
	get_tree().reload_current_scene()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player != null:
		player.connect("player_died", Callable(self, "game_over"))
		player.player_arrived.connect(decide_true_ending)
	#if evolved_player != null:
		
		#evolved_player.player_arrived.connect(decide_true_ending)
		#print("evolved_player 있음")
	new_game()
	#true_ending.connect("player_arrived", Callable(self, "decide_true_ending"))
	

func decide_true_ending():
	if true_ending_triggered:
		return
	print("is_true_ending = true")
	is_true_ending = true
	

func show_true_ending_ui():
	true_ending.show_true_ending()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_true_ending and !true_ending_triggered:
		show_true_ending_ui()
		true_ending_triggered = true
		
