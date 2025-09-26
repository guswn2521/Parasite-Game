extends Node2D
@onready var boss_zone: TileMapLayer = $BossZone
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boss_zone.visible = false
	boss_zone.collision_enabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func block_boss_zone():
	print("보스존 막기 시작!!!!!!")
	boss_zone.visible = true
	animation_player.play()
	boss_zone.collision_enabled = true
