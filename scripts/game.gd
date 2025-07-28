extends Node2D

@export var mob_scene: PackedScene
@onready var player: CharacterBody2D = $Players/player
@onready var start_timer: Timer = $Timers/StartTimer
@onready var mob_timer: Timer = $Timers/MobTimer
@onready var monsters: Node = $Monsters
@onready var mob_spawn_location: PathFollow2D = $MobPath/MobSpawnLocation

func new_game():
	GameManager.dna = 0
	mob_timer.start()

func _on_mob_timer_timeout() -> void:
	print("monster 생성")
	var mob = mob_scene.instantiate()
	mob_spawn_location.progress_ratio = randf()
	mob.position = mob_spawn_location.position
	mob.position.y = -40
	print("mob position : ")
	print(mob.position)
	
	
	monsters.add_child(mob)
	
func game_over():
	mob_timer.stop()
	print("game_over")
	start_timer.start()

func _on_start_timer_timeout() -> void:
	get_tree().reload_current_scene()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("player_died", Callable(self, "game_over"))
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
