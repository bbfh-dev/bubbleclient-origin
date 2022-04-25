extends Panel


func set_status(icon: String, label: String, description: String = '') -> void:
	$Icon/Icon.play(icon)
	$Container/Label.set_text(label)
	$Container/Description.set_text(description)
