extends Control

func _process(delta: float) -> void:
	if $Icon.animation == 'spinner':
		$Icon.set_rotation($Icon.get_rotation() * PI * 2 * delta)
	else:
		$Icon.set_rotation(0)

func set_icon(icon: String) -> void:
	$Icon.play(icon)
