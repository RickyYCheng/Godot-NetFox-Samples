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

var network_id := 1:
	set(id):
		network_id = id
		input.set_multiplayer_authority(id)

func _ready() -> void:
	rollback_synchronizer.process_settings()

var tick : int
# ATTENTION: The _rollback_tick on the client side only executes owned nodes  
# If other nodes need to be executed, use _predict instead: because we need to predict inputs, which is undeniable  
# The same applies to the state machine. If we need to execute a state machine not owned by the current client,  
# we also need _predict, since we don't know the inputs of non-owned nodes.  
# In this example, we did not synchronize Label:text but instead synchronized the state of the state machine.  
# On the client side, we executed the owned state machine via _rollback_tick  
# and executed the non-owned state machine via _predict.  
# In this example, for simplicity, the state machine's state requires no input, so we didn't need to predict inputs.  
# NOTE: Obviously, _predict won't execute when there are inputs, so the best approach is to directly synchronize the state.
func _rollback_tick(delta: float, tick: int, is_fresh: bool) -> void:
	self.tick = tick
	
	_apply_movement_from_input(delta, tick)
	
	#TODO: maybe enable save only on server
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

func _on_state_a_state_stepped() -> void:
	$Label.text = "State A"
	
	#if not multiplayer.is_server() and not input.is_multiplayer_authority():
		#print(tick)
	
	if (tick / 60) % 2 == 0:
		state_chart.send_event("to_state_b")

func _on_state_b_state_stepped() -> void:
	$Label.text = "State B"
	
	#if not multiplayer.is_server() and not input.is_multiplayer_authority():
		#print(tick)
	
	if (tick / 60) % 2 != 0:
		state_chart.send_event("to_state_a")

func _on_input_predict(tick: int) -> void:
	self.tick = tick
	state_chart.step()
