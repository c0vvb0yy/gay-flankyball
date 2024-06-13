extends Node2D
class_name Game


var team_members_player := [CONST.CHARACTER_1, CONST.CHARACTER_PLAYER, CONST.CHARACTER_1]
var team_members_enemy := [CONST.CHARACTER_1,CONST.CHARACTER_1,CONST.CHARACTER_1]
var distance_to_target:=250.0
var arena_height := 700.0

func _ready() -> void:
	initiate_match()

func get_extents() -> Vector2:
	var width = distance_to_target * 2
	var aspect_ratio = get_viewport_rect().size.x / get_viewport_rect().size.y
	var target_y = aspect_ratio / width
	
	var extents := Vector2(width, target_y)
	# add padding
	extents.x += 50
	extents.y += 50
	
	return extents

func get_center():
	return $TargetBottleSpawnPosition.global_position

func add_player(character:String, allied:bool, delay:=0.0):
	var team_members:int
	if allied:
		team_members = team_members_player.size()
	else:
		team_members = team_members_enemy.size()
	var participant
	if character == CONST.CHARACTER_PLAYER:
		participant = preload("res://Entities/participants/Player/player.tscn").instantiate()
	else:
		participant = preload("res://Entities/participants/agents/agent.tscn").instantiate()
	$Participants.add_child(participant)
	participant.set_character(character)
	if allied:
		participant.add_to_group("ally")
	else:
		participant.add_to_group("enemy")
	
	var center = get_center()
	var count_in_team := get_tree().get_node_count_in_group("ally")
	var p0 = 0#-arena_height * 0.5
	var p1 = arena_height# * 0.5
	var dt = abs(p1-p0) / float(team_members)
	var t = 0.5#0.5 * dt + (count_in_team - 1) * dt
	var height:float = p0 + (p1-p0) * t
	
	participant.position = Vector2(-center.x if allied else center.x, height)
	# TODO: after delay, the player enters from off screen
	# when they have reached their goal opsition, they emit a signal to reduce blockers here
	# when 0 blockers are reached, call start_match

func initiate_match():
	reset_target_bottle()
	for i in team_members_player.size():
		add_player(team_members_player[i], true, i * randf_range(1.5, 2.5))
	for i in team_members_enemy.size():
		add_player(team_members_enemy[i], false, i * randf_range(1.5, 2.5))

func reset_target_bottle():
	var target_bottle := $TargetBottle
	target_bottle.position = $TargetBottleSpawnPosition.position

func start_match():
	pass
