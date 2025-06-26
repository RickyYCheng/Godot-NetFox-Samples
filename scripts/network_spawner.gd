class_name NetworkSpawner
extends Node

@export var scene : PackedScene
@export var root : Node
var _nodes : Dictionary = {}

func _ready() -> void:
	if root == null: root = owner

func spawn(id: int) -> void:
	if scene == null: return
	
	var node := scene.instantiate()
	node.player_id = id
	root.add_child(node, true)
	_nodes[id] = node

func despawn(id: int) -> void:
	var node : Node = _nodes.get(id, null)
	_nodes.erase(id)
	if node == null: return
	root.remove_child(node)
	node.queue_free()
