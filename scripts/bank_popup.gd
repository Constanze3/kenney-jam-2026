extends Label

func show_value(value: int, travel: Vector2, duration: float, spread: float) -> void:
	# Show how much money we just got.
	text = "+" + str(value)

	# Pick a slightly different direction each time.
	var movement := travel.rotated(randf_range(-spread / 2.0, spread / 2.0))

	# Scale from the middle if we animate it later.
	pivot_offset = size / 2

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		self,
		"position",
		position + movement,
		duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	await tween.finished
	queue_free()
