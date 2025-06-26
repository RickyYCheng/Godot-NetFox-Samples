class_name NetworkSpawner
extends Node

@export var host_spawn : bool = false
@export var scene : PackedScene
@export var root : Node
var _nodes : Dictionary = {}

func _enter_tree() -> void:
	NetworkEvents.on_server_start.connect(_on_server_start)
	NetworkEvents.on_server_stop.connect(_on_server_stop)

func _exit_tree() -> void:
	NetworkEvents.on_server_start.disconnect(_on_server_start)
	NetworkEvents.on_server_stop.disconnect(_on_server_stop)

func _on_server_start() -> void:
	NetworkEvents.on_peer_join.connect(_spawn)
	NetworkEvents.on_peer_leave.connect(_despawn)
	
	if host_spawn:
		_spawn(1)

func _on_server_stop() -> void:
	for id in _nodes: 
		_despawn(id)
	if host_spawn:
		_despawn(1)

func _ready() -> void:
	if root == null: root = owner

func _spawn(id: int) -> void:
	if scene == null: return
	
	var node := scene.instantiate()
	_nodes[id] = node
	node.network_id = id # NOTE: must before add_child. why?
	root.add_child(node, true)

func _despawn(id: int) -> void:
	var node: Node = _nodes.get(id, null)
	_nodes.erase(id)
	if node == null: return
	node.queue_free()
