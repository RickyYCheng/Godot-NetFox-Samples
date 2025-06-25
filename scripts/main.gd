extends Node2D


func _on_host_button_down() -> void:
	%NetworkManager.become_host(true)
	$UI/Button.hide()
	$UI/Join.hide()

func _on_join_button_down() -> void:
	%NetworkManager.join_as_client(0)
	$UI/Button.hide()
	$UI/Join.hide()
