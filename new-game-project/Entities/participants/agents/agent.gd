extends Participant

@onready var nav : NavigationAgent2D = $NavigationAgent2D

var can_reach_bottle := false
var reaction_time := 0.2

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	super(delta)
	if state == State.Defending:
		nav.target_position = GameWorld.game_stage.get_target_bottle_position()
		var deftness_offset = deftness #+ randf_range(deftness * -get_drunk_sway(), deftness * get_drunk_sway() * 0.3)
		global_position = lerp(global_position, nav.get_next_path_position(), 0.002 * deftness_offset)
		
		catcher.look_at(GameWorld.game_stage.get_target_bottle_position())
		catcher.rotate(get_drunk_sway() * 0.5)
		
		if can_reach_bottle:
			reaction_time -= delta
			if reaction_time <= 0:
				attempt_catch()
	

func set_active(value:bool):
	super(value)
	if active:
		var goal_position := GameWorld.game_stage.get_target_bottle_position()
		throw_bottle(goal_position - position, 30.0)


func _on_catcher_bottle_entered() -> void:
	can_reach_bottle = true


func _on_catcher_bottle_exited() -> void:
	can_reach_bottle = false
	reaction_time = 0.2
