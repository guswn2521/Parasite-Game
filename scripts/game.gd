extends Node2D

@export var mob_scene: PackedScene
@onready var mob_timer: Timer = $Timers/MobTimer
@onready var player: CharacterBody2D = $player
@onready var start_timer: Timer = $Timers/StartTimer

func game_over():
	mob_timer.stop()
	print("game_over")
	new_game()
	
func new_game():
	start_timer.start()

func _on_start_timer_timeout() -> void:
	print("df")
	mob_timer.start()


func _on_mob_timer_timeout() -> void:
	print("monster 생")
	var mob = mob_scene.instantiate()
	add_child(mob)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("player_died", Callable(self, "game_over"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
