extends Node2D

@onready
var targeter = $Targeter

@onready
var bottle = $Bottle

var bottle_thrown := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if(event.is_action_pressed("ui_accept")):
		if(!targeter.is_rotation_set):
			targeter.is_rotation_set = true
			return
		if(!targeter.is_length_set):
			targeter.is_length_set = true
			return
		if(!bottle_thrown):
			bottle_thrown = true
			throw_bottle()

func throw_bottle():
	print(targeter.pointer.transform.get_origin())
	bottle.apply_central_impulse(targeter.pointer.global_position)
	bottle.apply_torque_impulse(5000)
