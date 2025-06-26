class_name NetworkManager
extends Node

var _peer := ENetMultiplayerPeer.new()
var _clients := []

func _enter_tree() -> void:
	NetworkEvents.on_server_start.connect(_on_server_start)
	NetworkEvents.on_server_stop.connect(_on_server_stop)

func _exit_tree() -> void:
	NetworkEvents.on_server_start.disconnect(_on_server_start)
	NetworkEvents.on_server_stop.disconnect(_on_server_stop)

func _on_server_start() -> void:
	NetworkEvents.on_peer_join.connect(_on_peer_join)
	NetworkEvents.on_peer_leave.connect(_on_peer_leave)

func _on_server_stop() -> void:
	NetworkEvents.on_peer_join.disconnect(_on_peer_join)
	NetworkEvents.on_peer_leave.disconnect(_on_peer_leave)
	_clients.clear()

func _on_peer_join(id: int) -> void:
	_clients.push_back(id)

func _on_peer_leave(id: int) -> void:
	_clients.erase(id)

func _condition(cond: Callable, timeout: float = 5.0) -> Error:
	timeout = Time.get_ticks_msec() + timeout * 1000
	while not cond.call():
		await get_tree().process_frame
		if Time.get_ticks_msec() > timeout:
			return ERR_TIMEOUT
	return OK

func start_server(port: int, timeout: float = 5.0) -> Error:
	if connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED: 
		return ERR_ALREADY_IN_USE
	
	_peer.create_server(port)
	multiplayer.multiplayer_peer = _peer
	
	await _condition(func():
		return connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
	, timeout)
	
	if connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return ERR_CANT_OPEN
	
	await NetworkEvents.on_server_start
	
	return OK

func start_client(addr: String, port: int, timeout: float = 5.0) -> Error:
	if connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED: 
		return ERR_ALREADY_IN_USE
	
	_peer.create_client(addr, port)
	multiplayer.multiplayer_peer = _peer
	
	await _condition(func(): 
		return connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
	, timeout)
	
	if connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return ERR_CANT_CONNECT
	
	await NetworkEvents.on_client_start
	
	return OK

func peer() -> MultiplayerPeer: return _peer

func connection_status() -> MultiplayerPeer.ConnectionStatus:
	if multiplayer.multiplayer_peer != _peer: 
		return MultiplayerPeer.CONNECTION_DISCONNECTED
	
	return _peer.get_connection_status()

## ret: if server then _clients else []
func clients() -> Array: 
	return _clients

func close() -> void: _peer.close()
