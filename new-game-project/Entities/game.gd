extends Node2D
class_name Game

var participants_allied : Array[Participant] = []
var participants_enemy : Array[Participant] = []
var turn_order : Array[Participant] = []
var turn_order_index := 0
var defender_index_allied := 0 # determines which team member has to run to the target bottle to fix it
var defender_index_enemy := 0
var team_members_allied := [CONST.CHARACTER_1, CONST.CHARACTER_PLAYER, CONST.CHARACTER_1]
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
		team_members = team_members_allied.size()
	else:
		team_members = team_members_enemy.size()
	var participant:Participant
	if character == CONST.CHARACTER_PLAYER:
		participant = preload("res://Entities/participants/Player/player.tscn").instantiate()
	else:
		participant = preload("res://Entities/participants/agents/agent.tscn").instantiate()
	$Participants.add_child(participant)
	participant.set_character(character)
	participant.set_allied(allied)
	if allied:
		participants_allied.append(participant)
	else:
		participants_enemy.append(participant)
	var center = get_center()
	var count_in_team:int
	if allied:
		count_in_team = get_tree().get_node_count_in_group("ally")
	else:
		count_in_team = get_tree().get_node_count_in_group("enemy")
	var segment_length = 1.0 / (team_members + 1)
	segment_length *= arena_height
	var goal_position := Vector2(center.x - distance_to_target if allied else center.x + distance_to_target, (-center.y*0.5) + segment_length * count_in_team)
	
	participant.position = goal_position
	if allied:
		participant.position.x -= 100
	else:
		participant.position.x += 100
	participant.position.y += randf_range(-20, 20)
	
	var t = create_tween()
	t.tween_property(participant, "position", goal_position, randf_range(0.7, 3.5))
	t.tween_callback(remove_player_blocker)
	# TODO: after delay, the player enters from off screen
	# when they have reached their goal opsition, they emit a signal to reduce blockers here
	# when 0 blockers are reached, call start_match

var player_blockers := 0
func initiate_match():
	participants_enemy.clear()
	participants_allied.clear()
	turn_order_index = 0
	player_blockers = team_members_enemy.size() + team_members_allied.size()
	reset_target_bottle()
	for i in team_members_allied.size():
		add_player(team_members_allied[i], true, i * randf_range(1.5, 2.5))
	for i in team_members_enemy.size():
		add_player(team_members_enemy[i], false, i * randf_range(1.5, 2.5))

func remove_player_blocker():
	player_blockers -= 1
	if player_blockers <= 0:
		start_match()

func reset_target_bottle():
	var target_bottle := $TargetBottle
	target_bottle.position = $TargetBottleSpawnPosition.position

func start_match():
	print("start")
	# build turn order
	var player_count = team_members_enemy.size() + team_members_allied.size()
	for i in player_count:
		if i % 2 == 0:# enemy on odds so allied team always goes first
			turn_order.append(participants_enemy[i / 2])
		else:
			turn_order.append(participants_allied[(i-1) / 2])
	turn_order[turn_order_index].set_active(true)

func trigger_out_of_bounds():
	print("out of bounds")
	pass
	# animation for out of bounds
	# reset bottle
	# next turn

func _on_out_of_bounds_body_entered(body: Node2D) -> void:
	if body is ProjectileBottle:
		trigger_out_of_bounds()
