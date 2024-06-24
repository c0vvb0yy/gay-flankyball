extends Node

var properties := {}
var property_listeners := {}

func listen(listener:Node, property:String, immediate_callback:=false):
	var listeners : Array = property_listeners.get(property, [])
	if not listeners.has(listeners):
		listeners.append(listener)
	property_listeners[property] = listeners
	
	if immediate_callback:
		listener.on_property_change(property, of(property), of(property))

func of(property_name:String, default:Variant=null):
	return properties.get(property_name, default)

# func on_property_change(property_name:String, new_value, old_value):
func apply(property_name:String, new_value:Variant):
	var listeners : Array = property_listeners.get(property_name, [])
	var old_value : Variant = of(property_name)
	
	for listener in listeners:
		listener.on_property_change(property_name, new_value, old_value)
	
	
