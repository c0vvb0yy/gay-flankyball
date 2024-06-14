extends Node2D
class_name Targeter

@export
var rotation_speed : float
@export
var line_extension_speed: float
@export
var max_line_length: float

@onready
var line :Line2D = $Line2D
@onready
var pointer :Sprite2D = $Pointer

var is_rotation_set : bool = false
var is_length_set : bool = false

var spread := 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_spread(0.001)

func set_spread(value:float):
	spread = abs(spread)
	spread = value
	var visualizer : Line2D = find_child("SpreadVisualizeLine")
	var spread_top : Node2D = find_child("SpreadTop")
	var spread_bottom : Node2D = find_child("SpreadBottom")
	visualizer.visible = spread != 0
	update_spread_visuals()

func update_spread_visuals():
	var spread_top : Node2D = find_child("SpreadTop")
	var spread_bottom : Node2D = find_child("SpreadBottom")
	var visualizer : Line2D = find_child("SpreadVisualizeLine")
	spread_top.position.x = pointer.position.x + pointer.texture.get_size().x
	spread_bottom.position.x = pointer.position.x + pointer.texture.get_size().x
	spread_top.position.y -= spread * get_force()
	spread_top.position.x -= spread * get_force()
	spread_bottom.position.y += spread * get_force()
	spread_bottom.position.x -= spread * get_force()
	if spread > 0:
		visualizer.clear_points()
		visualizer.add_point(spread_top.position)
		var mid_point = position
		mid_point.x += pointer.position.x + pointer.texture.get_size().x
		visualizer.add_point(mid_point)
		visualizer.add_point(spread_bottom.position)

func get_force() -> float:
	return (pointer.global_position - global_position).length()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!is_rotation_set):
		rotate_aim_line(delta)
	if(is_rotation_set && ! is_length_set):
		extend_and_shrink_aim_line(delta)
	#line.get_point_position(1) = pointer.transform.get_origin()
	line.set_point_position(1, pointer.transform.get_origin())
	update_spread_visuals()

func extend_and_shrink_aim_line(delta):
	pointer.transform.origin.x += delta * line_extension_speed
	if(pointer.transform.origin.x > max_line_length || pointer.transform.origin.x < 0):
		line_extension_speed = -line_extension_speed

func rotate_aim_line(delta):
	self.transform = self.transform.rotated(delta * rotation_speed)
	if(rad_to_deg(self.transform.get_rotation()) > 50 || rad_to_deg(self.transform.get_rotation()) < -50):
		rotation_speed = -rotation_speed
