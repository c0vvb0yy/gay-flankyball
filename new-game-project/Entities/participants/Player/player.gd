extends Node2D

@onready var targeter : Targeter = $Targeter
var bottle_thrown := false

var force_modifier := 30.0

func _input(event):
	if(event.is_action_pressed("ui_accept")):
		if(!targeter.is_rotation_set):
			targeter.is_rotation_set = true
			return
		if(!targeter.is_length_set):
			targeter.is_length_set = true
			bottle_thrown = true
			throw_bottle()

func set_character(character:String):
	pass

func throw_bottle():
	var bottle = preload("res://Entities/Targeter/projectile_bottle.tscn").instantiate()
	GameWorld.game_stage.add_child(bottle)
	bottle.global_position = global_position
	bottle.launch_bottle(targeter.pointer.position.normalized(), targeter.pointer.position.length() * force_modifier)
