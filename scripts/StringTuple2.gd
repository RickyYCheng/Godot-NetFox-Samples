class_name StringTuple2 
extends Resource

@export var neg: String = ""
@export var pos: String = ""

func _to_string() -> String:
	return "(%s, %s)" % [neg, pos]
