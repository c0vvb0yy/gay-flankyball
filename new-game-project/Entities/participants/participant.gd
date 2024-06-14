extends Node2D
class_name Participant

## which shape is used for catching incoming bottles
@export var catch_shape : Polygon2D
## peed at which the target bottle is put back and the participant moves
@export var deftness := 30.0
@export var throw_force := 10.0
const BASE_THROW_FORCE := 0.3
## modifies deftness, accuracy and throw strength. no idea how to use this
@export var alcohol_tolerance := 1.0
const BASE_ALCOHOL_TOLERANCE := 15.0
## we need to launch the projectile in a cone. this defines the spread of it
@export var accuracy := 10.0

func _ready() -> void:
	set_active(false)

func set_active(value:bool):
	pass

func set_allied(allied:bool):
	if allied:
		add_to_group("ally")
	else:
		add_to_group("enemy")
	find_child("Sprite").flip_h = not allied

func set_character(character:String):
	pass
	# set sprite and stuff
