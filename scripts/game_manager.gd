extends Node

var dna = 0
var players: Node2D = null
#@onready var players = get_tree().root.get_node("Game/Players")

func _ready() -> void:
	players = get_tree().root.get_node("Game/Players")

func add_item():
	print("아이템 먹음")
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
		print("dna 사용. 남은 dna : ", dna)
	
