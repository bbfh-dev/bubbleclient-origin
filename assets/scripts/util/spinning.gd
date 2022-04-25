extends TextureRect


func _process(delta: float) -> void:
	set_rotation(get_rotation() + PI * 2 * delta)
