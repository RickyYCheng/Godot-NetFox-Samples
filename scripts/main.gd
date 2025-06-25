extends Node2D

func _on_host_button_down() -> void:
	%NetworkManager.start_server(8877, true)
	$UI/Button.hide()
	$UI/Join.hide()

func _on_join_button_down() -> void:
	%NetworkManager.start_client("127.0.0.1", 8877)
	$UI/Button.hide()
	$UI/Join.hide()
