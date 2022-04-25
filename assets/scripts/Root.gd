extends Control

export var MINECRAFT : String
export var BUBBLECLIENT : String
export var VERSION : String
export var PROFILES : String
export var ram_size : int


func set_minecraft_dir(value: String) -> void:
	self.MINECRAFT = value

func set_bubbleclient_dir(value: String) -> void:
	self.BUBBLECLIENT = value

func set_version(value: String) -> void:
	self.VERSION = value

func set_profiles_file(value: String) -> void:
	self.PROFILES = value
