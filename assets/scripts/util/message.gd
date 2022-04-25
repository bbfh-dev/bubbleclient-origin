extends Panel

signal on_continue_pressed
export var current_value : int = 0

func _process(delta: float) -> void:
	if $ProgressBar.is_visible():
		$ProgressBar.value = lerp($ProgressBar.value, float(current_value), 0.5)

func set_status(icon: String, label: String, description: String = '', prompt: Array = []) -> void:
	$Icon.set_icon(icon)
	$Container/Label.set_text(label)
	$Container/Description.set_text(description)
	
	$Container/RAMPrompt.hide()
	$ContinuePrompt.hide()
	$DownloadPrompt.hide()
	$ProgressBar.hide()
	if 'RAM' in prompt:
		$Container/RAMPrompt.show()
	if 'Continue' in prompt:
		$ContinuePrompt.show()
	if 'Download' in prompt:
		$DownloadPrompt.show()
	if 'Progress' in prompt:
		$ProgressBar.show()


func _on_ContinuePrompt_pressed() -> void:
	emit_signal('on_continue_pressed')


func _on_DownloadPrompt_pressed() -> void:
	OS.shell_open('https://fabricmc.net/use/installer')


func _on_RAMPrompt_value_changed(value: float) -> void:
	$Container/RAMPrompt/Value.set_text(str(value) + ' GB')
	Root.ram_size = int(value)
