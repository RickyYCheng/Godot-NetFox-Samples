extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@onready var rollback_synchronizer = $RollbackSynchronizer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var input: PlayerInput

@export var network_id := 1:
	set(id):
		network_id = id
		input.set_multiplayer_authority(id)

func _ready() -> void:
	rollback_synchronizer.process_settings()

func _rollback_tick(delta: float, tick: int, is_fresh: bool) -> void:
	_apply_movement_from_input(delta)

func _apply_movement_from_input(delta: float) -> void:
	_force_update_is_on_floor()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	elif input.input_jump > 0:
		# Handle jump.
		velocity.y = JUMP_VELOCITY * input.input_jump
	
	# Get the input direction: -1, 0, 1
	var direction = input.input_direction
	
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
