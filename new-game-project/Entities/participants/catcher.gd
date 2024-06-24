extends Area2D


signal bottle_entered()
signal bottle_exited()

var has_bottle := false

func _on_body_entered(body: Node2D) -> void:
	if body is TargetBottle:
		emit_signal("bottle_entered")
		has_bottle = true

func _on_body_exited(body: Node2D) -> void:
	if body is TargetBottle:
		emit_signal("bottle_exited")
		has_bottle = false
