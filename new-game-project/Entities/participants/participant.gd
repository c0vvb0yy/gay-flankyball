extends Node2D
class_name Participant

enum State{
	Defending,
	Aiming,
	Idle,
	Drinking
}
var state := State.Idle

@onready var catcher : Node2D = $Catcher

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

var active := false
var alcohol_level := 0.0

var drinking_bottle:Node2D
var start_position

signal participant_finished_drinking(participant:Participant)

func get_drunk_sway():
	var sway = sin(GameWorld.time)
	# TODO this is wrong
	var amp := alcohol_level / alcohol_tolerance
	return sway# * amp

func _ready() -> void:
	set_active(false)
	var bottle = preload("res://Entities/participants/drinking_bottle.tscn").instantiate()
	add_child(bottle)
	bottle.bottle_empty.connect(emit_signal.bind("participant_finished_drinking", self))
	drinking_bottle = bottle
	drinking_bottle.position.x += 20

func _process(delta: float) -> void:
	if state == State.Drinking:
		alcohol_level += drinking_bottle.take_sip(delta)

func set_active(value:bool):
	active = value

func set_allied(allied:bool):
	if allied:
		add_to_group("ally")
	else:
		add_to_group("enemy")
	find_child("Sprite").flip_h = not allied

func set_character(character:String):
	pass
	# set sprite and stuff


func throw_bottle(throw_direction:Vector2, force:float):
	for bottle : ProjectileBottle in get_tree().get_nodes_in_group("projectile"):
		bottle.queue_free()
	var bottle = preload("res://Entities/Targeter/projectile_bottle.tscn").instantiate()
	GameWorld.game_stage.add_child(bottle)
	GameWorld.game_stage.thrown_bottle = bottle
	bottle.global_position = global_position
	throw_direction = throw_direction.normalized()
	bottle.launch_bottle(throw_direction, force * (BASE_THROW_FORCE + throw_force))
	set_active(false)

func start_defending():
	state = State.Defending

func start_drinking():
	state = State.Drinking

func stun():
	pass

func start_idling():
	state = State.Idle

func attempt_catch():
	if catcher.has_bottle:
		GameWorld.game_stage.game.reset_target_bottle()
		GameWorld.game_stage.game.start_next_round()
		reset_to_start_position()
	else:
		stun()

func reset_to_start_position():
	# TODO: vfx
	global_position = start_position
