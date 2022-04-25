extends Control

const ORIGIN = preload('res://source/Origin.tscn')


func _ready() -> void:
	$AnimationPlayer.play('RESET')
	yield(get_tree().create_timer(0.5), 'timeout')
	$AnimationPlayer.play('boot_up')
	$Logo/AnimatedSprite.playing = true
	yield(get_tree().create_timer(1.5), 'timeout')
	$HTTPRequest.request('https://raw.githubusercontent.com/bubblefish-dev/bubbleclient-server/main/response.json')


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if response_code != 200:
		$Panel/Label.set_text('An error occured. Code: ' + str(response_code) + '\nAnother attempt in 10 seconds...')
		yield(get_tree().create_timer(10), 'timeout')
		$HTTPRequest.request('https://raw.githubusercontent.com/bubblefish-dev/bubbleclient-server/main/response.json')
	else:
		var file = File.new()
		file.open('user://response.json', File.WRITE)
		file.store_string(body.get_string_from_utf8())
		file.close()
		
		$Panel/Label.set_text('Preparing to launch')
		
		Root.set_minecraft_dir(str(OS.get_environment('APPDATA') if OS.get_environment('APPDATA') else OS.get_environment('HOME')) + '/.minecraft')
		Root.set_bubbleclient_dir(str(OS.get_environment('APPDATA') if OS.get_environment('APPDATA') else OS.get_environment('HOME')) + '/.minecraft/BubbleClient')
		Root.set_version('1.0.0')
		
		var dir = Directory.new()
		dir.make_dir_recursive(Root.BUBBLECLIENT + '/resourcepacks')
		dir.make_dir_recursive(Root.BUBBLECLIENT + '/config')
		dir.make_dir_recursive(Root.BUBBLECLIENT + '/mods')
		
		if file.open(Root.MINECRAFT + '/launcher_profiles.json', File.READ) == OK:
			Root.set_profiles_file(file.get_as_text())
		else:
			$Panel/Label.set_text('Error: Minecraft Launcher isn\'t isntalled')
			yield(get_tree().create_timer(3), 'timeout')
			get_tree().quit(0)
		
		get_tree().change_scene_to(ORIGIN)
