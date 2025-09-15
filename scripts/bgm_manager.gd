extends Node

const FADE_DURATION := 3.0
const MAX_DB :=0
const MUTE_DB := -80
var current_bgm_path:String = ""
var bgm_player:AudioStreamPlayer

func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.stream = preload("res://assets/sounds/start_title.mp3")
	bgm_player.play()
	
func _process(delta: float) -> void:
	pass

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
