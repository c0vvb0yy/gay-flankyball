extends Node2D

var total_volume := 15.0

signal bottle_empty()

func take_sip(volume:float):
	if volume >= total_volume:
		emit_signal("bottle_empty")
	total_volume = max(total_volume - volume, 0)
	$Label.text = str(total_volume)
