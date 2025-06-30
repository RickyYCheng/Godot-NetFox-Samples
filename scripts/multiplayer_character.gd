extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const BUFFERED_JUMP_DURATION = .4

@onready var rollback_synchronizer = $RollbackSynchronizer

#region: state-chart and its save & load
@onready var state_chart: StateChart = $StateChart
@onready var state_chart_save := _serialized_state_chart()

func _serialized_state_chart() -> SerializedStateChart:
	if not state_chart._state.active: return null
	return StateChartSerializer.serialize(state_chart)

func _save() -> void:
	var save := _serialized_state_chart()
	if save == null: return
	state_chart_save = save

func _load() -> void:
	if state_chart_save == null: return
	StateChartSerializer.deserialize(state_chart_save, state_chart)
	if state_chart._state == null: return

#endregion

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var input: PlayerInput

var network_id := 1

@rpc("any_peer", "call_local")
func _spawn(id: int) -> void:
	network_id = id
	input.set_multiplayer_authority(id)

func _ready() -> void:
	rollback_synchronizer.process_settings()
	test = Resource.new()
	test.set_meta("foo", 0)
	test_str = var_to_str(test)

var tick : int
func _rollback_tick(delta: float, tick: int, is_fresh: bool) -> void:
	self.tick = tick
	
	_apply_movement_from_input(delta, tick)
	
	_load()
	state_chart.step()
	_save()

func _apply_movement_from_input(delta: float, tick: int) -> void:
	_force_update_is_on_floor()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	elif input.jump.just_pressed_tick + BUFFERED_JUMP_DURATION * NetworkTime.tickrate >= tick:
		# Handle jump.
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction: -1, 0, 1
	var direction = input.move_lr
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor

func _force_update_is_on_floor() -> void:
	var old_velocity = velocity
	velocity = Vector2.ZERO
	move_and_slide()
	velocity = old_velocity

@onready var label: Label = $Label
var test : Resource
var test_str : String

func _on_state_a_state_entered() -> void:
	test = str_to_var(test_str)
	test.set_meta("foo", 0)
	test_str = var_to_str(test)

func _on_state_a_state_stepped() -> void:
	if input.jump.just_pressed_tick == tick:
		state_chart.send_event("to_state_b")

func _on_state_b_state_entered() -> void:
	test = str_to_var(test_str)
	test.set_meta("foo", 1)
	test_str = var_to_str(test)

func _on_state_b_state_stepped() -> void:
	if input.jump.just_pressed_tick == tick:
		state_chart.send_event("to_state_a")
