class_name PlayerInput
extends Node

signal predict(tick: int)

const _EMPTY_ACTION_DICT := {
	"strength": 0,
	"pressed_tick": -INF, # FIXME: maybe use int
	"just_pressed_tick": -INF, 
	"just_released_tick": -INF,
}

@export var action_names: PackedStringArray = []
@export var axes: Dictionary[String, StringTuple2] = {}
@export var vectors: Dictionary[String, StringTuple4] = {}

var actions : Dictionary
var _backup : Dictionary

func _get(property: StringName) -> Variant:
	if property in actions: 
		return actions[property]
	elif property in axes:
		var neg := axes[property].neg
		var pos := axes[property].pos
		return actions[pos].strength - actions[neg].strength
	elif property in vectors:
		var neg_x := vectors[property].neg_x
		var pos_x := vectors[property].pos_x
		var neg_y := vectors[property].neg_y
		var pos_y := vectors[property].pos_y
		var x : float = actions[pos_x].strength - actions[neg_x].strength
		var y : float = actions[pos_y].strength - actions[neg_y].strength
		return Vector2(x, y).normalized()
	return null

func _ready() -> void:
	NetworkTime.before_tick_loop.connect(_gather)
	NetworkTime.after_tick.connect(_reset)
	NetworkRollback.after_prepare_tick.connect(_predict)
	
	for action in action_names:
		_backup[action] = _EMPTY_ACTION_DICT.duplicate(true)
	actions = _backup.duplicate(true) # deep clone

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

func _predict(tick: int) -> void:
	if not owner.rollback_synchronizer.is_predicting():
		# Not predicting, nothing to do
		return
	
	predict.emit(tick)

func _reset(delta: float, tick: int) -> void:
	_samples = 0
	
	for action in action_names:
		_backup[action].strength = 0.
