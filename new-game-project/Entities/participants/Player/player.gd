extends Participant

@onready var targeter : Targeter = $Targeter
var bottle_thrown := false

var speed = 4.25
var acceleration = 800
var deceleration = 1000
var velocity = Vector2.ZERO
var axis = Vector2.ZERO

func _ready() -> void:
	super()

func _input(event):
	var left_click := false
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			left_click = true
	if (event.is_action_pressed("ui_accept") or left_click) and state == State.Aiming:
		if not targeter.is_rotation_set:
			targeter.is_rotation_set = true
			return
		if not targeter.is_length_set:
			targeter.is_length_set = true
			bottle_thrown = true
			throw_bottle_targeted()
	if state == State.Defending:
		catcher.look_at(get_global_mouse_position())
		#catcher.rotate(get_drunk_sway() * 0.5)
		if left_click:
			attempt_catch()
			print("hsdgfhsdg")

func _physics_process(delta: float) -> void:
	if state != State.Defending:
		return
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if input_direction != Vector2.ZERO:
		var target_velocity = speed * input_direction
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		position += velocity
		#position = lerp(position, position + input * deftness, 0.1)

func set_active(value:bool):
	await  get_tree().process_frame
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


func _on_catcher_bottle_entered() -> void:
	print("bottle enter")


func _on_catcher_bottle_exited() -> void:
	print("bottle exit")
	pass # Replace with function body.
