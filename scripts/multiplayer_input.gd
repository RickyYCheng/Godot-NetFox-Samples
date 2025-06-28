class_name PlayerInput
extends Node

var move_lr : float

var _jump : Vector4 = Vector4()
var _jump_buffer : Vector4 = Vector4()

func _ready() -> void:
	NetworkTime.before_tick_loop.connect(_gather)
	NetworkTime.after_tick.connect(_reset)

var _samples := 0
func _process(delta: float) -> void:
	_samples += 1
	
	if Input.is_action_pressed("jump"):
		_jump_buffer.y = NetworkTime.tick
	if Input.is_action_just_pressed("jump"):
		_jump_buffer.z = NetworkTime.tick
	if Input.is_action_just_released("jump"):
		_jump_buffer.w = NetworkTime.tick

func _gather() -> void:
	if not is_multiplayer_authority():
		return
	
	move_lr = Input.get_axis("move_l", "move_r")
	
	_jump.y = _jump_buffer.y
	_jump.z = _jump_buffer.z
	_jump.w = _jump_buffer.w

func _reset(delta: float, tick: int) -> void:
	_samples = 0
	
	_jump_buffer.y = 0
	_jump_buffer.z = 0
	_jump_buffer.w = 0
