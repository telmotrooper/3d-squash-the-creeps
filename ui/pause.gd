extends Control

export (PackedScene) var title_screen
const draw_distance_text = "Draw Distance: %d"
const sensitivity_text = "Mouse Sensitivity: %.2f"
const music_volume_text = "Music Volume: %d"
const sound_volume_text = "Sound Volume: %d"

func _ready():
  $MainPause/HBoxContainer/LeftContainer/GrassOptionButton.select(Configuration.get_value("graphics", "grass_amount"))
  
  if (GameState.MapName): # TODO: Find a way to find option from label (maybe iterate through the items?)
    if (GameState.MapName == 'height_map'):
      $MainPause/HBoxContainer/RightContainer/MapOptionButton.select(0)
    elif (GameState.MapName == 'test_map'):
      $MainPause/HBoxContainer/RightContainer/MapOptionButton.select(1)
  
  $MainPause/HBoxContainer/LeftContainer/DrawDistanceLabel.text = draw_distance_text % Configuration.get_value("graphics", "draw_distance")
  $MainPause/HBoxContainer/LeftContainer/DrawDistanceSlider.value = Configuration.get_value("graphics", "draw_distance")
  
  $MainPause/HBoxContainer/LeftContainer/SensitivityLabel.text = sensitivity_text % Configuration.get_value("controls", "mouse_sensitivity")
  $MainPause/HBoxContainer/LeftContainer/SensitivitySlider.value = Configuration.get_value("controls", "mouse_sensitivity")
  
  $MainPause/HBoxContainer/RightContainer/MusicVolumeLabel.text = music_volume_text % Configuration.get_value("audio", "music_volume")
  $MainPause/HBoxContainer/RightContainer/MusicVolumeSlider.value = Configuration.get_value("audio", "music_volume")
  
  $MainPause/HBoxContainer/RightContainer/SoundVolumeLabel.text = sound_volume_text % Configuration.get_value("audio", "sound_volume")
  $MainPause/HBoxContainer/RightContainer/SoundVolumeSlider.value = Configuration.get_value("audio", "sound_volume")

func _on_DrawDistanceSlider_value_changed(value):
  Configuration.update_setting("graphics", "draw_distance", value)
  $MainPause/HBoxContainer/LeftContainer/DrawDistanceLabel.text = draw_distance_text % value
  GameState.Player.set_draw_distance(value)

func _on_SensitivitySlider_value_changed(value):
  Configuration.update_setting("controls", "mouse_sensitivity", value)
  $MainPause/HBoxContainer/LeftContainer/SensitivityLabel.text = sensitivity_text % value

func _on_MusicVolumeSlider_value_changed(value):
  Configuration.update_setting("audio", "music_volume", value)
  $MainPause/HBoxContainer/RightContainer/MusicVolumeLabel.text = music_volume_text % value
  Configuration.set_volume("Music", value)

func _on_SoundVolumeSlider_value_changed(value):
  Configuration.update_setting("audio", "sound_volume", value)
  $MainPause/HBoxContainer/RightContainer/SoundVolumeLabel.text = sound_volume_text % value
  Configuration.set_volume("Sound", value)

func pause():
  get_tree().paused = not get_tree().paused
  visible = get_tree().paused
  if visible:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
  else:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
  # TODO: Improve this when another menu page is needed.
  if event.is_action_pressed("pause"):
    if $MainPause.visible:
      pause()
    else:
      _on_ControlsBackButton_pressed()

func _on_ResumeButton_pressed():
  pause()

func _on_MainMenuButton_pressed():
  var error = get_tree().change_scene_to(title_screen)
  if (error):
    print("Error: Unable to load Title Screen.")
  
  pause()
  Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_ExitButton_pressed():
  get_tree().quit()

func _on_ToggleFullscreenButton_pressed():
  OS.window_fullscreen = !OS.window_fullscreen
  Configuration.update_setting("graphics", "fullscreen", OS.window_fullscreen)

func _on_GrassOptionButton_item_selected(index):
  GameState.update_grass(index)


func _on_MapOptionButton_item_selected(index):
  var map_name = $MainPause/HBoxContainer/RightContainer/MapOptionButton.get_item_text(index)
  GameState.change_map(map_name)
  pause()


func _on_ControlsButton_pressed():
  $MainPause.visible = false
  $PauseControls.visible = true


func _on_ControlsBackButton_pressed():
  $MainPause.visible = true
  $PauseControls.visible = false


func _on_ReloadMapButton_pressed():
  get_tree().reload_current_scene()
