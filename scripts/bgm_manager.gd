extends Node

const FADE_DURATION := 3.0
const MAX_DB :=0
const MUTE_DB := -80
var current_bgm_path:String = ""
var current_index = 0
var bgm_player:AudioStreamPlayer
var bgm_list = [
	"res://assets/sounds/1_Evening Harmony.ogg",
	"res://assets/sounds/2_Strange Worlds.ogg",
	"res://assets/sounds/3_Sunlight Through Leaves.ogg",
	"res://assets/sounds/4_Cuddle Clouds.ogg",
	"res://assets/sounds/5_Floating Dream.ogg",
	"res://assets/sounds/6_Whispering Woods.ogg"
]

func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	# 자동로드되면 타이틀bgm 재생.
	bgm_player.stream = load("res://assets/sounds/start_title.mp3")
	bgm_player.play()
	bgm_player.finished.connect(_on_bgm_finished)
	
func _process(delta: float) -> void:
	pass

# game씬에서 bgm_list를 반복
func play_bgm_list():
	bgm_player.stream = load(bgm_list[current_index])
	fade_in(bgm_player)

func _on_bgm_finished():
	current_index = (current_index + 1) % bgm_list.size()
	play_bgm_list()

func fade_in(player: AudioStreamPlayer) -> void:
	player.play()
	var tween = create_tween()
	tween.tween_property(player, "volume_db", MAX_DB, FADE_DURATION)

func fade_out(player:AudioStreamPlayer) -> void:
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80, 2.0).connect("finished", func(): 
		player.stop()
		)

func play_bgm(bgm_path: String):
	if current_bgm_path == bgm_path:
		return
	#fade_out(bgm_player)
	current_bgm_path = bgm_path
	bgm_player.stream = load(bgm_path)
	fade_in(bgm_player)
