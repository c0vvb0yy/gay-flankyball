extends Participant

@onready var targeter : Targeter = $Targeter
var bottle_thrown := false



func _ready() -> void:
	super()

func _input(event):
	if not active:
		return
	if event.is_action_pressed("ui_accept") and state == State.Aiming:
		if not targeter.is_rotation_set:
			targeter.is_rotation_set = true
			return
		if not targeter.is_length_set:
			targeter.is_length_set = true
			bottle_thrown = true
			throw_bottle_targeted()
	if state == State.Defending:
		$Catcher.look_at(get_local_mouse_position())
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				attempt_catch()

func set_active(value:bool):
	super(value)
	state = State.Aiming
	$Targeter.visible = active

func throw_bottle_targeted():
	var spread = targeter.spread
	spread = randf_range(-spread, spread)
	var shoot_direction := (targeter.pointer.global_position - targeter.global_position)
	var shoot_force : float = targeter.get_force() * 0.1
	spread *= shoot_force
	shoot_direction.y += spread
	shoot_direction = shoot_direction.normalized()
	throw_bottle(shoot_direction, shoot_force)
	state = State.Idle

func start_defending():
	super()
	$Catcher.visible = true
