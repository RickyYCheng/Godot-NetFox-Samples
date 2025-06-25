extends Node

@export var _players_spawn_node: Node

var enet_network_scene := preload("res://scenes/enet_network.tscn")
var active_network

func _build_multiplayer_network() -> void:
	if not active_network:
		MultiplayerManager.multiplayer_mode_enabled = true
		_set_active_network(enet_network_scene)

func _set_active_network(active_network_scene: PackedScene) -> void:
	var network_scene_initialized = active_network_scene.instantiate()
	active_network = network_scene_initialized
	active_network._players_spawn_node = _players_spawn_node
	add_child(active_network)

func become_host(is_dedicated_server: bool = false) -> void:
	_build_multiplayer_network()
	MultiplayerManager.host_mode_enabled = not is_dedicated_server
	active_network.become_host()
	
func join_as_client(lobby_id: int = 0) -> void:
	_build_multiplayer_network()
	active_network.join_as_client(lobby_id)
	
func list_lobbies() -> void:
	_build_multiplayer_network()
	active_network.list_lobbies()
