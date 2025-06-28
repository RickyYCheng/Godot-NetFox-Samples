class_name PlayerInput
extends Node

const _EMPTY_ACTION_DICT := {
	"strength": 0,
	"pressed_tick": -INF, # FIXME: maybe use int
	"just_pressed_tick": -INF, 
	"just_released_tick": -INF,
}

<<<<<<< HEAD
var _move_l_buffer := move_l
var _move_r_buffer := move_r
var _jump_buffer := jump
=======
@export var action_names: PackedStringArray
var actions : Dictionary
var _backup : Dictionary

func _get(property: StringName) -> Variant:
	if property not in action_names: return null
	return actions[property]
>>>>>>> main

func _ready() -> void:
	NetworkTime.before_tick_loop.connect(_gather)
	NetworkTime.after_tick.connect(_reset)
	
	for action in action_names:
		_backup[action] = _EMPTY_ACTION_DICT.duplicate(true)

var _samples := 0
func _process(delta: float) -> void:
	_samples += 1
	
	for action in action_names:
		_backup[action].strength += Input.get_action_strength(action)
		if Input.is_action_pressed(action):
			_backup[action].pressed_tick = NetworkTime.tick
		if Input.is_action_just_pressed(action):
			_backup[action].just_pressed_tick = NetworkTime.tick
		if Input.is_action_just_released(action):
			_backup[action].just_released_tick = NetworkTime.tick

func _gather() -> void:
	if not is_multiplayer_authority():
		return
	
	actions = _backup.duplicate(true) # deep clone
	for action in action_names:
		if _samples == 0: continue
		actions[action].strength /= _samples

func _reset(delta: float, tick: int) -> void:
	_samples = 0
	
	for action in action_names:
		_backup[action].strength = 0.
