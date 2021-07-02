extends Control

const sensitivity_text = "Mouse Sensitivity: %.2f"

func _ready():
  $VBoxContainer/SensitivityLabel.text = sensitivity_text % Configuration.get_value("controls", "mouse_sensitivity")
  $VBoxContainer/SensitivitySlider.value = Configuration.get_value("controls", "mouse_sensitivity")

func _on_SensitivitySlider_value_changed(value):
  Configuration.update_setting("controls", "mouse_sensitivity", value)
  $VBoxContainer/SensitivityLabel.text = sensitivity_text % value


func pause():
  get_tree().paused = not get_tree().paused
  visible = get_tree().paused
  if visible:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
  else:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
  if event.is_action_pressed("pause"):
    pause()

func _on_ResumeButton_pressed():
  pause()

func _on_ExitButton_pressed():
  get_tree().quit()

func _on_ToggleFullscreenButton_pressed():
  OS.window_fullscreen = !OS.window_fullscreen
  Configuration.update_setting("display", "fullscreen", OS.window_fullscreen)
