extends Control
class_name GameStage


enum TextStyle {
	ToBottom,
	ToCharacter,
}

@export var text_style := TextStyle.ToBottom


var dialog_box_tween : Tween
var dialog_box_offset := Vector2.ZERO
var actor_name := ""
var cg := ""
var cg_position := ""
var is_name_container_visible := false

@onready var cg_roots := [find_child("CGBottomContainer"), find_child("CGTopContainer")]
var blockers := 1

@onready var game = $Game
var callable_upon_blocker_clear:Callable

func _ready():
	GameWorld.game_stage = self
	
	remove_blocker()
	$Camera2D.position = $Game.get_center()
	#$Camera2D.zoom.x = $Game.get_extents().x / get_viewport_rect().size.x
	#$Camera2D.zoom.y = $Game.get_extents().x / get_viewport_rect().size.x
	#$Camera2D.zoom *= 2
	#printt(get_viewport_rect().size, $Game.get_extents())

func get_target_bottle_position() -> Vector2:
	return $Game.find_child("TargetBottle").global_position

func show_ui():
	pass
	#find_child("VNUI").visible = true

func hide_ui():
	pass
	#find_child("VNUI").visible = false

func set_cg(cg_name:String, fade_in_duration:float, cg_node:TextureRect):
	var cg_root : Control = cg_node.get_parent()
	cg_root.modulate.a = 0.0
	cg_root.visible = true
	
	cg_node.texture = load(str("res://sample/diisis_intro/cg/", cg_name, ".png"))
	var t = create_tween()
	t.tween_property(cg_root, "modulate:a", 1.0, fade_in_duration)
	
	cg = cg_name

func set_cg_top(cg_name:String, fade_in_duration:float):
	cg_position = "top"
	set_cg(cg_name, fade_in_duration, find_child("CGTopContainer").get_node("CGTex"))

func set_cg_bottom(cg_name:String, fade_in_duration:float):
	cg_position = "bottom"
	set_cg(cg_name, fade_in_duration, find_child("CGBottomContainer").get_node("CGTex"))

func set_text_style(style:TextStyle):
	text_style = style
	if text_style == TextStyle.ToBottom:
		find_child("TextContainer").custom_minimum_size.x = 454
		find_child("RichTextLabel").custom_minimum_size.x = 500
	elif text_style == TextStyle.ToCharacter:
		find_child("TextContainer").custom_minimum_size.x = 230
		find_child("RichTextLabel").custom_minimum_size.x = 230



func set_callable_upon_blocker_clear(callable:Callable):
	callable_upon_blocker_clear = callable

func serialize() -> Dictionary:
	var result := {}
	
	
	
	return result

func deserialize(data:Dictionary):
	pass

func remove_blocker():
	blockers -= 1
	#if blockers <= 0:
		#callable_upon_blocker_clear.call()

