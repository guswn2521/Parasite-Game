extends Node2D
@onready var boss_zone: TileMapLayer = $BossZone
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	boss_zone.visible = false
	boss_zone.collision_enabled = false

func block_boss_zone():
	boss_zone.visible = true
	animation_player.play()
	boss_zone.collision_enabled = true
