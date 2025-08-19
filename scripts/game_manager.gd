extends Node

signal dna_changed(new_dna)
signal player_nums_changed(player_nums)
var players: Node2D = null

var _dna: float = 0
var dna: float:
	get:
		return _dna
	set(value):
		_dna = value
		emit_signal("dna_changed", _dna)

var _player_nums: int = 1
var player_nums: int:
	get:
		return _player_nums
	set(value):
		_player_nums = value
		emit_signal("player_nums_changed", _player_nums)

func _ready() -> void:
	players = get_tree().root.get_node("Game/Players")
	# 게임 창 크기
	var window_size = Vector2i(3000, 1200)
	# 화면 전체 크기
	var screen_size = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	# 화면에서 위치 계산
	var center_pos = (screen_size - window_size) / 2
	var custom_pos = center_pos - Vector2i(0, 1000)
	# 창 위치 설정
	DisplayServer.window_set_position(custom_pos)
	# 창 크기 원하는 크기로 변경
	DisplayServer.window_set_size(window_size)

func add_item():
	if players == null or !is_instance_valid(players):
		print("player가 null")
		players = get_tree().root.get_node("Game/Players")
		if players == null:
			print("또 null")
			return
	
	var cnt_players = float(players.get_child_count())
	dna += 1 / cnt_players
	print(dna)

func use_item():
	if dna > 0 :
		dna -= 1
		player_nums += 1
		print("dna 사용. 남은 dna : ", dna)
	
