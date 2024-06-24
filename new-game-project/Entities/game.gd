extends Node2D
class_name Game

var participants_allied : Array[Participant] = []
var participants_enemy : Array[Participant] = []
var finished_allied : Array[Participant] = []
var finished_enemy : Array[Participant] = []
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

func is_attacker_allied() -> bool:
	var active_participant = turn_order[turn_order_index]
	return participants_allied.has(active_participant)

func get_center():
	return $TargetBottleSpawnPosition.global_position

func add_participant(character:String, allied:bool, delay:=0.0):
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
	participant.participant_finished_drinking.connect(on_participant_finished_drinking)
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
	t.tween_callback(remove_participant_blocker)
	participant.start_position = goal_position
	# TODO: after delay, the player enters from off screen
	# when they have reached their goal opsition, they emit a signal to reduce blockers here
	# when 0 blockers are reached, call start_match

var participant_blockers := 0
func initiate_match():
	participants_enemy.clear()
	participants_allied.clear()
	turn_order_index = 0
	participant_blockers = team_members_enemy.size() + team_members_allied.size()
	reset_target_bottle()
	for i in team_members_allied.size():
		add_participant(team_members_allied[i], true, i * randf_range(1.5, 2.5))
	for i in team_members_enemy.size():
		add_participant(team_members_enemy[i], false, i * randf_range(1.5, 2.5))

func remove_participant_blocker():
	participant_blockers -= 1
	if participant_blockers <= 0:
		start_match()

func reset_target_bottle():
	print("resetting")
	for bottle : ProjectileBottle in get_tree().get_nodes_in_group("projectile"):
		bottle.queue_free()
	var target_bottle : RigidBody2D = $TargetBottle
	target_bottle.position = $TargetBottleSpawnPosition.position
	target_bottle.linear_velocity = Vector2.ZERO
	target_bottle.angular_velocity = 0
	target_bottle.rotation = 0

func on_participant_finished_drinking(participant:Participant):
	if participant in participants_allied:
		finished_allied.append(participant)
		if finished_allied.size() == participants_allied.size():
			print("allied victory")
	elif participant in participants_enemy:
		finished_enemy.append(participant)
		if finished_enemy.size() == participants_enemy.size():
			prints("enemy victory")

func start_match():
	get_tree().create_timer(2)
	# build turn order
	var participant_count = team_members_enemy.size() + team_members_allied.size()
	for i in participant_count:
		if i % 2 == 0:# enemy on odds so allied team always goes first
			turn_order.append(participants_enemy[i / 2])
		else:
			turn_order.append(participants_allied[(i-1) / 2])
	turn_order[turn_order_index].set_active(true)

func start_defense():
	var defender:Participant
	if is_attacker_allied():
		defender = participants_enemy[defender_index_enemy]
		for part in participants_allied:
			part.start_drinking()
	else:
		defender = participants_allied[defender_index_allied]
		for part in participants_enemy:
			part.start_drinking()
	
	defender.start_defending()

func start_next_round():
	await get_tree().create_timer(2)
	for participant : Participant in turn_order:
		participant.start_idling()
	if is_attacker_allied():
		defender_index_enemy = wrapi(defender_index_enemy + 1, 0, participants_enemy.size())
	else:
		defender_index_allied = wrapi(defender_index_allied + 1, 0, participants_allied.size())
	turn_order_index = wrapi(turn_order_index + 1, 0, turn_order.size())
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


func _on_target_bottle_body_entered(body: Node) -> void:
	if body is ProjectileBottle:
		start_defense()
