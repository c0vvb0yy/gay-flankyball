extends Participant

@onready var targeter : Targeter = $Targeter
var bottle_thrown := false

func _ready() -> void:
	super()

func _input(event):
	if(event.is_action_pressed("ui_accept")):
		if not targeter.is_rotation_set:
			targeter.is_rotation_set = true
			return
		if not targeter.is_length_set:
			targeter.is_length_set = true
			bottle_thrown = true
			throw_bottle()



func throw_bottle():
	var bottle = preload("res://Entities/Targeter/projectile_bottle.tscn").instantiate()
	GameWorld.game_stage.add_child(bottle)
	bottle.global_position = global_position
	var spread = targeter.spread
	spread = randf_range(-spread, spread)
	var shoot_direction := (targeter.pointer.global_position - targeter.global_position)
	var shoot_force : float = targeter.get_force() * 0.1
	spread *= shoot_force
	shoot_direction.y += spread
	shoot_direction = shoot_direction.normalized()
	bottle.launch_bottle(shoot_direction, shoot_force * (BASE_THROW_FORCE + throw_force))
