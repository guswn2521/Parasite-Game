extends Node

var dna = 0
@onready var players = get_tree().root.get_node("Game/Players")

func add_item():
	var cnt_players = float(players.get_child_count())
	dna += 1 / cnt_players
	print(dna)

func use_item():
	if dna > 0 :
		dna -= 1
		print("dna 사용. 남은 dna : ", dna)
	
