class_name PlayerInput
extends Node

var move_l := Vector4(0, -1e10, -1e10, -1e10)
var move_r := Vector4(0, -1e10, -1e10, -1e10)
var jump := Vector4(0, -1e10, -1e10, -1e10)

var _move_l_buffer := Vector4(0, -1e10, -1e10, -1e10)
var _move_r_buffer := Vector4(0, -1e10, -1e10, -1e10)
var _jump_buffer := Vector4(0, -1e10, -1e10, -1e10)

func _ready() -> void:
	NetworkTime.before_tick_loop.connect(_gather)
	NetworkTime.after_tick.connect(_reset)

var _samples := 0
func _process(delta: float) -> void:
	_samples += 1
	
	_jump_buffer = _make_buffer(_jump_buffer, "jump")
	_move_l_buffer = _make_buffer(_move_l_buffer, "move_l")
	_move_r_buffer = _make_buffer(_move_r_buffer, "move_r")

func _gather() -> void:
	if not is_multiplayer_authority():
		return
	
	jump = _gather_from(_jump_buffer)
	move_l = _gather_from(_move_l_buffer)
	move_r = _gather_from(_move_r_buffer)

func _reset(delta: float, tick: int) -> void:
	_samples = 0
	
	_jump_buffer.x = 0
	_move_l_buffer.x = 0
	_move_r_buffer.x = 0

func _make_buffer(_buffer: Vector4, action: String) -> Vector4:
	_buffer.x += Input.get_action_strength(action)
	if Input.is_action_pressed(action):
		_buffer.y = NetworkTime.tick
	if Input.is_action_just_pressed(action):
		_buffer.z = NetworkTime.tick
	if Input.is_action_just_released(action):
		_buffer.w = NetworkTime.tick
	return _buffer
func _gather_from(_buffer: Vector4) -> Vector4:
	if _samples > 0:
		_buffer.x /= _samples
	return _buffer
