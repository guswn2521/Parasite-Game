extends CanvasLayer
@onready var dna_label: Label = $DNALabel

func _ready() -> void:
	var cnt_dna = int(GameManager.dna)
	dna_label.text = "DNA 개수 : %d " % cnt_dna
	GameManager.connect("dna_changed", Callable(self, "_on_dna_changed"))

func _on_dna_changed(new_dna):
	dna_label.text = "DNA 개수 : %d " % new_dna
