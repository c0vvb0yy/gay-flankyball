extends Node2D

@export
var rotation_speed : float
@export
var line_extension_speed: float
@export
var max_line_length: float

@onready
var line :Line2D = $Line2D
@onready
var pointer :Sprite2D = $Sprite2D

var is_rotation_set : bool = false
var is_length_set : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!is_rotation_set):
		rotate_aim_line(delta)
	if(is_rotation_set && ! is_length_set):
		extend_and_shrink_aim_line(delta)
	#line.get_point_position(1) = pointer.transform.get_origin()
	line.set_point_position(1, pointer.transform.get_origin())
	pass

func extend_and_shrink_aim_line(delta):
	pointer.transform.origin.x += delta * line_extension_speed
	if(pointer.transform.origin.x > max_line_length || pointer.transform.origin.x < 0):
		line_extension_speed = -line_extension_speed

func rotate_aim_line(delta):
	self.transform = self.transform.rotated(delta * rotation_speed)
	if(rad_to_deg(self.transform.get_rotation()) > 50 || rad_to_deg(self.transform.get_rotation()) < -50):
		rotation_speed = -rotation_speed
