extends Node2D

func _on_host_button_down() -> void:
	$UI/Host.hide()
	$UI/Join.hide()
	
	await %NetworkManager.start_server(8877)
	await %NetworkManager.until(MultiplayerPeer.CONNECTION_DISCONNECTED)
	
	$UI/Host.show()
	$UI/Join.show()

func _on_join_button_down() -> void:
	$UI/Host.hide()
	$UI/Join.hide()
	
	await %NetworkManager.start_client("127.0.0.1", 8877)
	await %NetworkManager.until(MultiplayerPeer.CONNECTION_DISCONNECTED)
	
	$UI/Host.show()
	$UI/Join.show()

func _on_close_button_down() -> void:
	%NetworkManager.close()
