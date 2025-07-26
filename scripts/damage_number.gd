extends Label


func show_damage(amount: int, is_critical: bool) -> void:
	text = str(amount)
	if is_critical:
		modulate = Color(1, 1, 0, 1) # 노란색
		scale = Vector2(1.5, 1.5) # 1.5배 확대
	else:
		modulate = Color(1, 1, 1, 1) # 흰색
		scale = Vector2(1, 1) # 1배
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 20, 1.0)
	tween.tween_property(self, "modulate:a", 0 , 1.0)
	tween.tween_callback(self.queue_free)
