extends VBoxContainer


func _ready() -> void:
	var file = File.new()
	file.open('user://response.json', File.READ)
	print(file.get_as_text())
	$Tabs/Home/Content.set_bbcode(JSON.parse(file.get_as_text()).get_result()['home'])
	$Tabs/About/Content.set_bbcode(JSON.parse(file.get_as_text()).get_result()['about'])
	file.close()
	$Status.set_status('done', 'Ready to be installed', Root.BUBBLECLIENT)
	$TaskManager.create_new_task()
	if not check_whether_fabric_installed():
		$TaskManager.manage_task('prompt', 'Please install FabricMC first', 'Choose 1.17.1', ['Download'])


func check_whether_fabric_installed() -> bool:
	var file = File.new()
	if file.open(Root.MINECRAFT + '/launcher_profiles.json', File.READ) != OK:
		return false
	
	var launcher_profiles = JSON.parse(file.get_as_text()).get_result()
	file.close()
	
	if not 'profiles' in launcher_profiles:
		return false
	
	for profile in launcher_profiles['profiles']:
		if profile == 'fabric-loader-1.17.1':
			$TaskManager.manage_task('prompt', 'Ready to be installed', Root.BUBBLECLIENT, ['Continue'])
			$TaskManager/FabricTimer.stop()
			yield($Tabs/Install/Content.get_child(0), 'on_continue_pressed')
			$TaskManager.install_bubbleclient()
			return true
	return false


func _on_Content_meta_clicked(meta) -> void:
	OS.shell_open(meta)


func _on_FabricTimer_timeout() -> void:
	check_whether_fabric_installed()
