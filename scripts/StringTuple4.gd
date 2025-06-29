class_name StringTuple4 
extends Resource

@export var neg_x: String = ""
@export var pos_x: String = ""
@export var neg_y: String = ""
@export var pos_y: String = ""

func _to_string() -> String:
	return "(%s, %s, %s, %s)" % [neg_x, pos_x, neg_y, pos_y]
