extends Node2D
var map_id : int
@onready var area_1: Area2D = $Area1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for area in get_tree().get_nodes_in_group("map_areas"):
		area.body_entered.connect(_on_area_body_entered.bind(area))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_body_entered(body, area) -> void:
	print("플레이어 %d 에 진입" %area.map_id)
	if body.name == "player":
		map_id = area.map_id
		BgmManager.play_bgm_for_map(map_id)
