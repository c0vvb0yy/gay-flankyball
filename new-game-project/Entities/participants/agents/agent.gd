extends Participant

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	super(delta)

func set_active(value:bool):
	super(value)
	if active:
		var goal_position := GameWorld.game_stage.get_target_bottle_position()
		throw_bottle(goal_position - position, 30.0)
