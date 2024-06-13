extends RigidBody2D
class_name ProjectileBottle

@export var tech_id:String
@export var faces := []

var start_right := false


var launch := false
var stop := false
var finished_roll := false
var launch_force:float
var launch_direction:Vector2
var still_cooldown := 2.0

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if linear_velocity.length() < 1:
		still_cooldown -= delta
		if still_cooldown <= 0.0:
			stop = true

func launch_bottle(direction:Vector2, force:float):
	launch_force = force
	launch_direction = direction
	launch = true
	set_process(true)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if stop:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		stop = false
	if launch:
		linear_velocity = Vector2(launch_direction * launch_force)
		angular_velocity = randf_range(-60, 60)
		launch = false
	if linear_velocity.length() <= 35:
		linear_velocity *= 0.5
	elif linear_velocity.length() <= 85:
		linear_velocity *= 0.9


