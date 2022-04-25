extends HTTPRequest

const MESSAGE = preload('res://source/origin/Message.tscn')
onready var container = get_parent().get_node('Tabs/Install/Content')
var download_in_progress := false
var current_file : String = ''
var MIGRATION_PROFILES = []
var MIGRATE_FROM = 0


func create_new_task():
	var child = MESSAGE.instance()
	container.add_child(child)
	container.move_child(child, 0)


func manage_task(state: String, label: String, description: String = '', prompt: Array = []) -> void:
	container.get_child(0).set_status(state, label, description, prompt)


func install_bubbleclient() -> void:
	for child in container.get_children():
		container.remove_child(child)
	create_new_task()
	manage_task('prompt', 'Alocate RAM', 'Choose at most 75% of your physical RAM', ['RAM', 'Continue'])
	yield(container.get_child(0), 'on_continue_pressed')
	
	var file = File.new()
	var dir = Directory.new()
	
	create_new_task()
	manage_task('prompt', 'Choose where to migrate from', 'Or leave it empty', ['Migrate', 'Continue'])
	if file.open(Root.MINECRAFT + '/launcher_profiles.json', File.READ) == OK:
		var profiles = JSON.parse(file.get_as_text()).get_result()['profiles']
		container.get_child(0).get_node('Container/OptionButton').add_item('Do not migrate')
		for profile in profiles:
			if 'gameDir' in profiles[profile]:
				MIGRATION_PROFILES.append(profiles[profile]['gameDir'])
			else:
				MIGRATION_PROFILES.append(Root.MINECRAFT)
			if 'name' in profiles[profile] and profiles[profile]['name'] != '':
				container.get_child(0).get_node('Container/OptionButton').add_item(profiles[profile]['name'])
			elif 'lastVersionId' in profiles[profile]:
				container.get_child(0).get_node('Container/OptionButton').add_item(profiles[profile]['lastVersionId'].replace('-', ' ').capitalize())
			else:
				container.get_child(0).get_node('Container/OptionButton').add_item(profile)
		file.close()
	yield(container.get_child(0), 'on_continue_pressed')
	MIGRATE_FROM = container.get_child(0).get_node('Container/OptionButton').get_selected_id()
	print(MIGRATE_FROM)
	manage_task('spinner', 'Reading mod list')
	
	file.open('user://response.json', File.READ)
	var response = JSON.parse(file.get_as_text()).get_result()
	manage_task('spinner', 'Preparing to install', str(response['mods'].size()) + ' Mods')
	yield(get_tree().create_timer(0.5), 'timeout')
	manage_task('done', 'Installing', str(response['mods'].size()) + ' Mods')
	
	dir.make_dir_recursive(Root.BUBBLECLIENT + '/mods')
	dir.make_dir_recursive(Root.BUBBLECLIENT + '/config')
	
	if MIGRATE_FROM != 0:
		dir.copy(MIGRATION_PROFILES[MIGRATE_FROM] + '/servers.dat', Root.BUBBLECLIENT + '/servers.dat')
		if dir.open(MIGRATION_PROFILES[MIGRATE_FROM] + '/resourcepacks') == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
				else:
					dir.copy(MIGRATION_PROFILES[MIGRATE_FROM] + '/resourcepacks/' + file_name, Root.BUBBLECLIENT + '/resourcepacks/' + file_name)
				file_name = dir.get_next()
	
	if not file.file_exists(Root.BUBBLECLIENT + '/options.txt'):
		file.open(Root.BUBBLECLIENT + '/options.txt', File.WRITE)
		file.store_string('version:2730\nautoJump:false\nautoSuggestions:true\nchatColors:true\nchatLinks:true\nchatLinksPrompt:true\nenableVsync:false\nentityShadows:true\nforceUnicodeFont:false\ndiscrete_mouse_scroll:false\ninvertYMouse:false\nrealmsNotifications:true\nreducedDebugInfo:false\nsnooperEnabled:true\nshowSubtitles:false\ntouchscreen:false\nfullscreen:false\nbobView:true\ntoggleCrouch:false\ntoggleSprint:false\ndarkMojangStudiosBackground:false\nmouseSensitivity:0.352112676056338\nfov:0.5\nscreenEffectScale:0.0\nfovEffectScale:0.0\ngamma:12.0\nrenderDistance:6\nentityDistanceScaling:1.0\nguiScale:0\nparticles:0\nmaxFps:260\ndifficulty:2\ngraphicsMode:0\nao:2\nbiomeBlendRadius:2\nrenderClouds:false\nresourcePacks:[\"vanilla\",\"Fabric Mods\",\"cullleaves/smartleaves\"]\nincompatibleResourcePacks:[]\nlastServer:\nlang:en_us\nchatVisibility:0\nchatOpacity:1.0\nchatLineSpacing:0.0\ntextBackgroundOpacity:0.5\nbackgroundForChatOnly:true\nhideServerAddress:false\nadvancedItemTooltips:false\npauseOnLostFocus:true\noverrideWidth:0\noverrideHeight:0\nheldItemTooltips:true\nchatHeightFocused:1.0\nchatDelay:0.0\nchatHeightUnfocused:0.44366195797920227\nchatScale:1.0\nchatWidth:0.721830985915493\nmipmapLevels:0\nuseNativeTransport:true\nmainHand:right\nattackIndicator:1\nnarrator:0\ntutorialStep:movement\nmouseWheelSensitivity:1.0\nrawMouseInput:true\nglDebugVerbosity:1\nskipMultiplayerWarning:true\nhideMatchedNames:true\njoinedFirstServer:false\nhideBundleTutorial:false\nsyncChunkWrites:false\nkey_key.attack:key.mouse.left\nkey_key.use:key.mouse.right\nkey_key.forward:key.keyboard.w\nkey_key.left:key.keyboard.a\nkey_key.back:key.keyboard.s\nkey_key.right:key.keyboard.d\nkey_key.jump:key.keyboard.space\nkey_key.sneak:key.keyboard.left.shift\nkey_key.sprint:key.keyboard.left.control\nkey_key.drop:key.keyboard.q\nkey_key.inventory:key.keyboard.e\nkey_key.chat:key.keyboard.t\nkey_key.playerlist:key.keyboard.tab\nkey_key.pickItem:key.mouse.middle\nkey_key.command:key.keyboard.slash\nkey_key.socialInteractions:key.keyboard.p\nkey_key.screenshot:key.keyboard.f2\nkey_key.togglePerspective:key.keyboard.f5\nkey_key.smoothCamera:key.keyboard.unknown\nkey_key.fullscreen:key.keyboard.f11\nkey_key.spectatorOutlines:key.keyboard.unknown\nkey_key.swapOffhand:key.keyboard.f\nkey_key.saveToolbarActivator:key.keyboard.unknown\nkey_key.loadToolbarActivator:key.keyboard.x\nkey_key.advancements:key.keyboard.l\nkey_key.hotbar.1:key.keyboard.1\nkey_key.hotbar.2:key.keyboard.2\nkey_key.hotbar.3:key.keyboard.3\nkey_key.hotbar.4:key.keyboard.4\nkey_key.hotbar.5:key.keyboard.5\nkey_key.hotbar.6:key.keyboard.6\nkey_key.hotbar.7:key.keyboard.7\nkey_key.hotbar.8:key.keyboard.8\nkey_key.hotbar.9:key.keyboard.9\nkey_key.custom_hud.enable:key.keyboard.unknown\nkey_key.custom_hud.cycleProfiles:key.keyboard.unknown\nkey_key.custom_hud.swapToProfile1:key.keyboard.unknown\nkey_key.custom_hud.swapToProfile2:key.keyboard.unknown\nkey_key.custom_hud.swapToProfile3:key.keyboard.unknown\nkey_Toggle Debug Menu:key.keyboard.f3\nkey_Toggle Selected Scripts:key.keyboard.unknown\nkey_Stop Selected Scripts:key.keyboard.unknown\nkey_Accurate Reverse:key.keyboard.unknown\nkey_Accurate Into:key.keyboard.unknown\nkey_Open Essential Client Menu:key.keyboard.unknown\nkey_Open Chunk Debug:key.keyboard.f6\nkey_Open Client Script:key.keyboard.unknown\nkey_key.healthindicators.toggle:key.keyboard.keypad.divide\nkey_key.boosted-brightness.next:key.keyboard.b\nkey_key.boosted-brightness.raise:key.keyboard.right.bracket\nkey_key.boosted-brightness.lower:key.keyboard.left.bracket\nkey_key.boosted-brightness.select1:key.keyboard.unknown\nkey_key.boosted-brightness.select2:key.keyboard.unknown\nkey_key.boosted-brightness.select3:key.keyboard.unknown\nkey_key.boosted-brightness.select4:key.keyboard.unknown\nkey_key.boosted-brightness.select5:key.keyboard.unknown\nkey_key.inventoryhud.toggle:key.keyboard.i\nkey_key.inventoryhud.openconfig:key.keyboard.o\nkey_key.inventoryhud.togglepot:key.keyboard.unknown\nkey_key.inventoryhud.togglearm:key.keyboard.unknown\nkey_key.inventoryhud.toggleall:key.keyboard.unknown\nkey_key.okzoomer.zoom:key.keyboard.c\nkey_key.okzoomer.decrease_zoom:key.keyboard.unknown\nkey_key.okzoomer.increase_zoom:key.keyboard.unknown\nkey_key.okzoomer.reset_zoom:key.keyboard.unknown\nkey_Freelook:key.keyboard.y\nkey_key.replaymod.playeroverview:key.keyboard.b\nkey_key.replaymod.lighting:key.keyboard.z\nkey_key.replaymod.quickmode:key.keyboard.q\nkey_key.replaymod.settings:key.keyboard.unknown\nkey_key.replaymod.marker:key.keyboard.m\nkey_key.replaymod.thumbnail:key.keyboard.n\nkey_key.replaymod.playpause:key.keyboard.p\nkey_key.replaymod.rollclockwise:key.keyboard.l\nkey_key.replaymod.rollcounterclockwise:key.keyboard.j\nkey_key.replaymod.resettilt:key.keyboard.k\nkey_key.replaymod.pathpreview:key.keyboard.h\nkey_key.replaymod.keyframerepository:key.keyboard.x\nkey_key.replaymod.clearkeyframes:key.keyboard.c\nkey_key.replaymod.synctimeline:key.keyboard.v\nkey_key.replaymod.positionkeyframe:key.keyboard.i\nkey_key.replaymod.positiononlykeyframe:key.keyboard.unknown\nkey_key.replaymod.timekeyframe:key.keyboard.o\nkey_key.replaymod.bothkeyframes:key.keyboard.unknown\nkey_keybind.name.ESSENTIAL_FRIENDS:key.keyboard.h\nkey_keybind.name.COSMETIC_STUDIO:key.keyboard.b\nkey_keybind.name.COSMETICS_VISIBILITY_TOGGLE:key.keyboard.o\nkey_keybind.name.ADD_FRIEND:key.keyboard.unknown\nkey_keybind.name.CHAT_PEEK:key.keyboard.z\nkey_keybind.name.INVITE_FRIENDS:key.keyboard.unknown\nkey_keybind.name.ZOOM:key.keyboard.insert\nsoundCategory_master:0.5033113\nsoundCategory_music:0.0\nsoundCategory_record:1.0\nsoundCategory_weather:0.5070422\nsoundCategory_block:1.0\nsoundCategory_hostile:1.0\nsoundCategory_neutral:1.0\nsoundCategory_player:1.0\nsoundCategory_ambient:1.0\nsoundCategory_voice:1.0\nmodelPart_cape:true\nmodelPart_jacket:true\nmodelPart_left_sleeve:true\nmodelPart_right_sleeve:true\nmodelPart_left_pants_leg:true\nmodelPart_right_pants_leg:true\nmodelPart_hat:true')
		file.close()
	
	if MIGRATE_FROM != 0:
		file.open(MIGRATION_PROFILES[MIGRATE_FROM] + '/options.txt', File.READ)
		var options = file.get_as_text()
		file.close()
		file.open(Root.BUBBLECLIENT + '/options.txt', File.WRITE)
		file.store_string(options)
		file.close()
	
	get_parent().get_node('Status').set_status('spinner', 'Installing the client', 'Do not close this app!')
	for mod in response['mods']:
		create_new_task()
		
		if mod['action'] == 'delete':
			manage_task('spinner', 'Deleting', mod['file'])
			if not file.file_exists(mod['file']):
				manage_task('done', 'Already deleted', mod['file'])
			else:
				dir.remove(mod['file'])
				manage_task('done', 'Deleted', mod['file'])
		
		if mod['action'] == 'download':
			manage_task('spinner', 'Resolving', mod['file'])
			if file.file_exists(Root.BUBBLECLIENT + '/mods/' + mod['file']):
				manage_task('done', 'Already installed', mod['file'])
			else:
				manage_task('spinner', 'Downloading', mod['file'] + ' (' + str(float(mod['size'] / 1024 / 1024)) + 'MB)', ['Progress'])
				container.get_child(0).get_node('ProgressBar').max_value = mod['size']
				current_file = Root.BUBBLECLIENT + '/mods/' + mod['file']
				download_file = current_file
				download_in_progress = true
				request('https://github.com/bubblefish-dev/bubbleclient-server/raw/main/mods/' + mod['file'])
				yield(get_tree().create_timer(0.5), 'timeout')
				while download_in_progress:
					if file.open(current_file, File.READ) == OK:
						container.get_child(0).current_value = int(file.get_len())
						file.close()
					yield(get_tree().create_timer(0.5), 'timeout')
				manage_task('done', 'Downloaded', mod['file'])
		
		if 'config' in mod:
			create_new_task()
			manage_task('spinner', 'Configuring', mod['file'])
			dir.make_dir_recursive(Root.BUBBLECLIENT + '/config' + mod['config']['dir'])
			file.open(Root.BUBBLECLIENT + '/config' + mod['config']['dir'] + '/' + mod['config']['file'], File.WRITE)
			if mod['config']['contents'] is String:
				file.store_string(mod['config']['contents'])
			else:
				file.store_string(JSON.print(mod['config']['contents'], '\t'))
			file.close()
			manage_task('done', 'Configured', mod['file'])
	
	create_new_task()
	manage_task('spinner', 'Setting up profile')
	if file.open(Root.MINECRAFT + '/launcher_profiles.json', File.READ_WRITE) == OK:
		var launcher_profiles = JSON.parse(file.get_as_text()).get_result()
		launcher_profiles['profiles']['fabric-loader-1.17.1']['name'] = 'BubbleClient 1.17.1'
		launcher_profiles['profiles']['fabric-loader-1.17.1']['icon'] = 'data:image/png;base64,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'
		launcher_profiles['profiles']['fabric-loader-1.17.1']['gameDir'] = Root.BUBBLECLIENT
		launcher_profiles['profiles']['fabric-loader-1.17.1']['javaArgs'] = '-Xmx' + str(Root.ram_size) + 'G -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M'
		file.store_string(JSON.print(launcher_profiles, '\t'))
		file.close()
	manage_task('done', 'Added profile')
	create_new_task()
	manage_task('done', 'Installation is complete!', 'You can close this window now.')
	get_parent().get_node('Status').set_status('done', 'Installation complete!')



func _on_TaskManager_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if response_code == 200:
		download_in_progress = false
	else:
		manage_task('fail', 'An error occured. Please try again later.', str(response_code))
		var dir = Directory.new()
		dir.remove(current_file)
		download_in_progress = false
