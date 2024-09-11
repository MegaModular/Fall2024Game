extends Control

func showHUD():
	visible = true

func hideHUD():
	visible = false


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_resume_pressed() -> void:
	Globals.isPaused = false
	hideHUD()
