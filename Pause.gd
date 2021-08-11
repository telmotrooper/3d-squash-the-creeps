extends Control

const draw_distance_text = "Draw Distance: %d"
const sensitivity_text = "Mouse Sensitivity: %.2f"
const music_volume_text = "Music Volume: %d"
const sound_volume_text = "Sound Volume: %d"

func _ready():
  $VBoxContainer/GrassOptionButton.select(Configuration.get_value("graphics", "grass_amount"))
  
  $VBoxContainer/DrawDistanceLabel.text = draw_distance_text % Configuration.get_value("graphics", "draw_distance")
  $VBoxContainer/DrawDistanceSlider.value = Configuration.get_value("graphics", "draw_distance")
  
  $VBoxContainer/SensitivityLabel.text = sensitivity_text % Configuration.get_value("controls", "mouse_sensitivity")
  $VBoxContainer/SensitivitySlider.value = Configuration.get_value("controls", "mouse_sensitivity")
  
  $VBoxContainer/MusicVolumeLabel.text = music_volume_text % Configuration.get_value("audio", "music_volume")
  $VBoxContainer/MusicVolumeSlider.value = Configuration.get_value("audio", "music_volume")
  
  $VBoxContainer/SoundVolumeLabel.text = sound_volume_text % Configuration.get_value("audio", "sound_volume")
  $VBoxContainer/SoundVolumeSlider.value = Configuration.get_value("audio", "sound_volume")

func _on_DrawDistanceSlider_value_changed(value):
  Configuration.update_setting("graphics", "draw_distance", value)
  $VBoxContainer/DrawDistanceLabel.text = draw_distance_text % value
  GameState.Player.set_draw_distance(value)

func _on_SensitivitySlider_value_changed(value):
  Configuration.update_setting("controls", "mouse_sensitivity", value)
  $VBoxContainer/SensitivityLabel.text = sensitivity_text % value

func _on_MusicVolumeSlider_value_changed(value):
  Configuration.update_setting("audio", "music_volume", value)
  $VBoxContainer/MusicVolumeLabel.text = music_volume_text % value
  Configuration.set_volume("Music", value)

func _on_SoundVolumeSlider_value_changed(value):
  Configuration.update_setting("audio", "sound_volume", value)
  $VBoxContainer/SoundVolumeLabel.text = sound_volume_text % value
  Configuration.set_volume("Sound", value)

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
  Configuration.update_setting("graphics", "fullscreen", OS.window_fullscreen)

func _on_GrassOptionButton_item_selected(index):
  GameState.update_grass(index)
