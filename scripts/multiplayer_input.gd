class_name PlayerInput
extends Node

var move_lr : float
var jump_pressed_tick : float
var jump_just_pressed_tick : float
var jump_released_tick : float
var _jump_pressed_tick : float
var _jump_just_pressed_tick : float
var _jump_released_tick : float

func _ready() -> void:
	NetworkTime.before_tick_loop.connect(_gather)
	NetworkTime.after_tick.connect(_reset)

var _samples := 0
func _process(delta: float) -> void:
	_samples += 1
	
	if Input.is_action_pressed("jump"):
		_jump_pressed_tick = NetworkTime.tick
	if Input.is_action_just_pressed("jump"):
		_jump_just_pressed_tick = NetworkTime.tick
	if Input.is_action_just_released("jump"):
		_jump_released_tick = NetworkTime.tick

func _gather() -> void:
	if not is_multiplayer_authority():
		return
	
	move_lr = Input.get_axis("move_l", "move_r")
	
	jump_pressed_tick = _jump_pressed_tick
	jump_just_pressed_tick = _jump_just_pressed_tick
	jump_released_tick = _jump_released_tick

func _reset(delta: float, tick: int) -> void:
	_samples = 0
	
	_jump_pressed_tick = 0
	_jump_just_pressed_tick = 0
	_jump_released_tick = 0
