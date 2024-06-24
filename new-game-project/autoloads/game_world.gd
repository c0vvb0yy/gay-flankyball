extends Node


var stage_root: StageRoot
var game_stage: GameStage
#var instruction_handler: InstructionHandler

## state of the match. paused during minigames (killing transphobes)
var match_paused:=false
## global game pause state
var paused:=false
var camera : Camera2D

var background := ""
var time := 0.0

enum MatchState{
	Aiming,
	Interrupted,
	ProjectileInAir,
	DefenseAndDrinking,
	Ended,
	Starting
}

func _ready() -> void:
	Data.apply("gameworld.matchstate", MatchState.Starting)

func _process(delta: float) -> void:
	time += delta

func serialize():
	var result := {}
	result["background"] = background
	#result["game_stage"] = game_stage.serialize()
	return result

#func deserialize(data:Dictionary):
	#if game_stage:
		#stage_root.set_background(data.get("background", CONST.BACKGROUND_WORKSHOP))
		#game_stage.deserialize(data.get("game_stage", {}))
		#pass
	#else:
		#print("game stage not set for gameworld deserialization")
