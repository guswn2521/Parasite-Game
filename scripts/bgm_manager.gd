extends Node
@onready var bgm_player: AudioStreamPlayer = $AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_bgm_for_map(map_id):
	var bgm_files = {
		1: "res://assets/sounds/1_Evening Harmony.ogg",
		2: "res://assets/sounds/2_Strange Worlds.ogg",
		3: "res://assets/sounds/3_Sunlight Through Leaves.ogg",
		4: "res://assets/sounds/4_Cuddle Clouds.ogg",
		5: "res://assets/sounds/5_Floating Dream.ogg",
		6: "res://assets/sounds/6_Whispering Woods.ogg"
	}
	bgm_player.stream = load(bgm_files[map_id])
	bgm_player.play()
