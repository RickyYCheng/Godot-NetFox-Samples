extends Node2D

func _on_host_button_down() -> void:
	%NetworkManager.start_server(8877, false)

func _on_join_button_down() -> void:
	%NetworkManager.start_client("127.0.0.1", 8877)

func _on_close_button_down() -> void:
	multiplayer.multiplayer_peer.close()
