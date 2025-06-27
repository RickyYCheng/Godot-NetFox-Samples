class_name NetworkSpawner
extends Node

@export var host_spawn : bool = false
@export var scene : PackedScene
@export var root : Node
var _nodes : Dictionary = {}

func _enter_tree() -> void:
	NetworkEvents.on_server_start.connect(_on_server_start)
	NetworkEvents.on_server_stop.connect(_on_stop)
	NetworkEvents.on_client_stop.connect(_on_stop)

func _exit_tree() -> void:
	NetworkEvents.on_server_start.disconnect(_on_server_start)
	NetworkEvents.on_server_stop.disconnect(_on_stop)
	NetworkEvents.on_client_stop.disconnect(_on_stop)

func _on_server_start() -> void:
	NetworkEvents.on_peer_join.connect(_spawn)
	NetworkEvents.on_peer_leave.connect(_despawn)
	
	if host_spawn:
		_spawn(1)

func _on_stop() -> void:
	# use _nodes.keys() instead of _nodes
	# since _despawn will erase dictionary
	#for id in _nodes.keys():
		#_despawn(id)
	
	for node in _nodes.values():
		node.queue_free()
	_nodes.clear()

func _ready() -> void:
	if root == null: root = owner

# NetworkEvents.on_peer_join calls only on server
# MultiplayerSpawner will spawn peers on clients
func _spawn(id: int) -> void:
	if scene == null: return
	
	var node := scene.instantiate()
	_nodes[id] = node
	root.add_child(node, true)
	
	if node.has_method("_spawn"):
		node._spawn.rpc(id)

# NetworkEvents.on_peer_join calls only on server
# MultiplayerSpawner will spawn peers on clients
func _despawn(id: int) -> void:
	var node: Node = _nodes.get(id, null)
	_nodes.erase(id)
	if node == null: return
	node.queue_free()
