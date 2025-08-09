extends Node2D

@export var mob_scene: PackedScene

@onready var player: CharacterBody2D = $Players/player
@onready var start_timer: Timer = $Timers/StartTimer
@onready var mob_timer: Timer = $Timers/MobTimer
@onready var monsters: Node = $Monsters
@onready var gameover: Control = $Players/player/Camera2D/Gameover
@onready var gameover_timer: Timer = $Players/player/Camera2D/Gameover/GameoverTimer

#@onready var gameover: Control = $Gameover
#@onready var gameover_timer: Timer = $Gameover/GameoverTimer

func new_game():
	gameover.visible = false
	GameManager.dna = 0
	mob_timer.start()

func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()
	mob.position = Vector2(-200,20)
	mob.position.y = -40
	print("몬스터 생성", mob.position)
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
	player.connect("player_died", Callable(self, "game_over"))
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
