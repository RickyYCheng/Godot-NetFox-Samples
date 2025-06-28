extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@onready var rollback_synchronizer = $RollbackSynchronizer

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

func _rollback_tick(delta: float, tick: int, is_fresh: bool) -> void:
	_apply_movement_from_input(delta, tick)

func _apply_movement_from_input(delta: float, tick: int) -> void:
	_force_update_is_on_floor()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	elif input._jump.z == tick:
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
