extends Node

const FADE_DURATION := 3.0
const MAX_DB :=0
const MUTE_DB := -80

@onready var player: Player = $"../Players/player"
@onready var area_1: Area2D = $Area1audio/Area1
@onready var area_2: Area2D = $Area2audio/Area2
@onready var area_3: Area2D = $Area3audio/Area3
@onready var area_4: Area2D = $Area4audio/Area4
@onready var area_5: Area2D = $Area5audio/Area5
@onready var area_6: Area2D = $Area6audio/Area6
@onready var area_1_audio: AudioStreamPlayer2D = $Area1audio
@onready var area_2_audio: AudioStreamPlayer2D = $Area2audio
@onready var area_3_audio: AudioStreamPlayer2D = $Area3audio
@onready var area_4_audio: AudioStreamPlayer2D = $Area4audio
@onready var area_5_audio: AudioStreamPlayer2D = $Area5audio
@onready var area_6_audio: AudioStreamPlayer2D = $Area6audio

func _ready() -> void:
	area_1_audio.volume_db = MUTE_DB
	area_2_audio.volume_db = MUTE_DB
	area_3_audio.volume_db = MUTE_DB
	area_4_audio.volume_db = MUTE_DB
	area_5_audio.volume_db = MUTE_DB
	area_6_audio.volume_db = MUTE_DB
	
	for area in get_tree().get_nodes_in_group("bgm_areas"):
		area.body_entered.connect(on_area_body_entered.bind(area))
		area.body_exited.connect(on_area_body_exited.bind(area))
func _process(delta: float) -> void:
	pass

func fade_in(player: AudioStreamPlayer2D) -> void:
	player.play()
	var tween = create_tween()
	tween.tween_property(player, "volume_db", MAX_DB, FADE_DURATION)

func fade_out(player:AudioStreamPlayer2D) -> void:
	var tween = create_tween()
	tween.tween_property(player, "volume_db", -80, 2.0).connect("finished", func(): 
		player.stop()
		)

func on_area_body_entered(body, area):
	if body.is_in_group("Players"):
		if area == area_1:
			fade_in(area_1_audio)
		if area == area_2:
			fade_in(area_2_audio)
		if area == area_3:
			fade_out(area_3_audio)
		if area == area_4:
			fade_out(area_4_audio)
		if area == area_5:
			fade_out(area_5_audio)
		if area == area_6:
			fade_out(area_6_audio)
		
func on_area_body_exited(body, area):
	if body.is_in_group("Players"):
		if area == area_1:
			fade_out(area_1_audio)
		if area == area_2:
			fade_out(area_2_audio)
		if area == area_3:
			fade_out(area_3_audio)
		if area == area_4:
			fade_out(area_4_audio)
		if area == area_5:
			fade_out(area_5_audio)
		if area == area_6:
			fade_out(area_6_audio)


# map_id 받아서 bgm 플레이
#func play_bgm_for_map(map_id):
	#var bgm_files = {
		#1: "res://assets/sounds/1_Evening Harmony.ogg",
		#2: "res://assets/sounds/2_Strange Worlds.ogg",
		#3: "res://assets/sounds/3_Sunlight Through Leaves.ogg",
		#4: "res://assets/sounds/4_Cuddle Clouds.ogg",
		#5: "res://assets/sounds/5_Floating Dream.ogg",
		#6: "res://assets/sounds/6_Whispering Woods.ogg"
	#}
	#bgm_player.stream = load(bgm_files[map_id])
	#bgm_player.play()
