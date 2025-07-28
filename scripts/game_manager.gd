extends Node

var dna = 0

func add_item():
	dna += 1
	print(dna)

func use_item():
	dna -= 1
	print(dna)
