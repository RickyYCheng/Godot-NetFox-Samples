extends Node

var multiplayer_scene = preload("res://scenes/multiplayer_character.tscn")

@export var _players_spawn_node: Node

func _ready() -> void:
	NetworkEvents.on_server_stop.connect(_server_stop)

func _server_stop() -> void:
	multiplayer.peer_connected.disconnect(_add_player_to_game)
	multiplayer.peer_disconnected.disconnect(_del_player)
	
	for node in _players_spawn_node.get_children():
		node.queue_free()

func start_server(port: int, is_host: bool) -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	
	if is_host:
		_add_player_to_game(1)

func _handle_stop() -> void:
	for node in _players_spawn_node.get_children():
		node.queue_free()

func start_client(addr: String, port: int) -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(addr, port)
	multiplayer.multiplayer_peer = peer

func _add_player_to_game(id: int) -> void:
	prints("[%s, %s]" % [multiplayer.is_server(), id], "Player %s joined the game!" % id)
	
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	_players_spawn_node.add_child(player_to_add, true)

func _del_player(id: int) -> void:
	print("Player %s left the game!" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
