extends CanvasLayer
@onready var dna_label: Label = $DNALabel
@onready var player_numbers: Label = $PlayerNumbers

func _ready() -> void:
	var cnt_dna = int(GameManager.dna)
	var player_cnt = GameManager.player_nums
	dna_label.text = "DNA 개수 : %d " % cnt_dna
	player_numbers.text = "모체 수 : %d" % player_cnt
	GameManager.connect("dna_changed", Callable(self, "_on_dna_changed"))
	GameManager.connect("player_nums_changed", Callable(self, "_on_player_nums_changed"))
	
func _on_dna_changed(new_dna):
	dna_label.text = "DNA 개수 : %d " % new_dna
	
func _on_player_nums_changed(player_nums: int) -> void:
	player_numbers.text = "모체 수 : %d" % player_nums
