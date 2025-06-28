class_name PlayerInput
extends Node

const _EMPTY_ACTION_DICT := {
	"strength": 0., 
	"pressed": false,
	"pressed_tick": 0,
	"just_pressed": false, 
	"just_pressed_tick": 0,
	"just_released": false,
	"just_released_tick": 0,
}

var _actions : Dictionary = {
	"move_l": _EMPTY_ACTION_DICT.duplicate(true),
	"move_r": _EMPTY_ACTION_DICT.duplicate(true),
	"move_u": _EMPTY_ACTION_DICT.duplicate(true),
	"move_d": _EMPTY_ACTION_DICT.duplicate(true),
	"jump": _EMPTY_ACTION_DICT.duplicate(true),
}

var _buffers : Dictionary = _actions.duplicate(true)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkTime.before_tick_loop.connect(_gather)
	NetworkTime.after_tick.connect(_reset)
	
	# register compounds
	_actions["move_lr"] = {"strength": 0.}
	_actions["move_ud"] = {"strength": 0.}

var _samples := 0
func _process(delta: float) -> void:
	_samples += 1
	
	for action in _buffers:
		_buffers[action].strength += Input.get_action_strength(action)
		if Input.is_action_pressed(action):
			# will not set to false until _reset
			_buffers[action].pressed = true
			_buffers[action].pressed_tick = NetworkTime.tick
		if Input.is_action_just_pressed(action):
			# will not set to false until _reset
			_buffers[action].just_pressed = true
			_buffers[action].just_pressed_tick = NetworkTime.tick
		if Input.is_action_just_released(action):
			# will not set to false until _reset
			_buffers[action].just_released = true
			_buffers[action].just_released_tick = NetworkTime.tick

func _gather() -> void:
	if not is_multiplayer_authority():
		return
	
	for action in _buffers:
		for prop in _EMPTY_ACTION_DICT:
			_actions[action][prop] = _buffers[action][prop]
		if _samples > 0:
			_actions[action].strength /= _samples
	
	# handle compounds
	_actions.move_lr.strength = _actions.move_r.strength - _actions.move_l.strength
	_actions.move_ud.strength = _actions.move_u.strength - _actions.move_d.strength

func _get(property: StringName) -> Variant:
	if property in _actions:
		return _actions[property]
	return null

func _reset(delta: float, tick: int) -> void:
	_samples = 0
	
	for action in _buffers:
		#NOTE: no ticks
		_buffers[action].strength = 0.
		_buffers[action].pressed = false
		_buffers[action].just_pressed = false
		_buffers[action].just_released = false
