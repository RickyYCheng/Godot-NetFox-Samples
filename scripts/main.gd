extends Node2D


func _on_host_button_down() -> void:
	%NetworkManager.become_host()
	$UI/Button.hide()
	$UI/Join.hide()

func _on_join_button_down() -> void:
	%NetworkManager.join_as_client()
	$UI/Button.hide()
	$UI/Join.hide()
