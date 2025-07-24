extends Node2D

@export var mob_scene: PackedScene
@onready var mob_timer: Timer = $Timers/MobTimer
@onready var player: CharacterBody2D = $player

func game_over():
	mob_timer.stop()
	print("game_over")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("player_died", Callable(self, "game_over"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
