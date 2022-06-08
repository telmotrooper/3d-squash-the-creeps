extends Node

var Player: KinematicBody
var Grass: Node
var MapName: String
var UserInterface: Control
var RetryCamera: Camera # Camera to be used when player dies.

var upgrades = {
  "double_jump": false,
  "mid_air_dash": false
}

var amount_of_gems := 0

var godot_heads_counter := 0
var total_godot_heads_in_map := 0

var godot_heads_collected = {
  "TestMap": {
    "FloatingGodotHead": false,
    "GrassGodotHead": false,
    "BeachGodotHead": false,
   },
  "MontainMap": {
    "GodotHead": false
   }
}

var global_progress = { "collected": 0, "total": 0, "percentage": 0.0 }
var progress = {}

# Backup this value so it can be used to start a new game.
var initial_godot_heads_collected = var2bytes(godot_heads_collected)

func add_gems(amount: int):
  UserInterface.show_hud()
  amount_of_gems += amount
  UserInterface.get_node("%GemLabel").text = "%d" % amount_of_gems

func initialize(): # Used in "New Game".
  godot_heads_collected = bytes2var(GameState.initial_godot_heads_collected)
  initialize_progress()
  amount_of_gems = 0

func initialize_progress():
  global_progress = { "collected": 0, "total": 0, "percentage": 0.0 }
  progress = {}
  
  for map_name in godot_heads_collected:
    progress[map_name] = { "collected": 0, "total": 0 }
    for entry in godot_heads_collected[map_name]:
      if godot_heads_collected[map_name][entry]:
        progress[map_name].collected += 1
        global_progress.collected += 1
      progress[map_name].total += 1
      global_progress.total += 1
    progress[map_name].percentage = float(progress[map_name].collected) / progress[map_name].total
  
  global_progress.percentage = float(global_progress.collected) / global_progress.total

func generate_progress_report(current_map):
  if progress.empty(): # Useful when starting map from editor.
    initialize_progress()
  
  # This function reads the "progress" dictionary and updates the "Progress" menu accordingly.
  # If current map is provided, we also update the HUD with map-specific progress.
  
  assert(is_instance_valid(UserInterface))

  var text = ""
  
  for map_name in godot_heads_collected:
    text += map_name + ": "
    text += "%d/%d (%.2f%%)   " % [progress[map_name].collected, progress[map_name].total, progress[map_name].percentage * 100]
  
  UserInterface.get_node("%ProgressButton").text = "Progress: %.2f%%" % [global_progress.percentage * 100]
  UserInterface.get_node("%World1Progress").text = text
  
  if current_map:
    UserInterface.get_node("%ScoreLabel").text = "%s / %s" % [progress[current_map].collected, progress[current_map].total]

func collect_godot_head(map_name, id):
  UserInterface.show_hud()
  GameState.godot_heads_collected[map_name][id] = true
  
  # Update progress.
  progress[map_name].collected += 1
  global_progress.collected += 1
  
  progress[map_name].percentage = float(progress[map_name].collected) / progress[map_name].total
  global_progress.percentage = float(global_progress.collected) / global_progress.total
  generate_progress_report(map_name)

func register_godot_head(map_name, id):
  if not map_name in godot_heads_collected:
    print("Warning: Update GameState to include '%s'." % map_name)
    godot_heads_collected[map_name] = {}
  
  if not id in godot_heads_collected[map_name]:
    print("Warning: Update GameState to include '%s'." % id)
    GameState.godot_heads_collected[map_name][id] = false

# This variable is used to work around a bug in Scatter on which,
# after "test_map" is reloaded, the modifiers are not re-inserted
# and we end up without any grass.
var ScatterModifierStackBackup: Array = []

const initial_grass = 3000

func update_grass(index: int = -1):
  if index == -1: # If called with no index, set the one from the configuration file.
    index = Configuration.get_value("graphics", "grass_amount")
    
  var multiplier = grass_index_to_multiplier(index)
  
  if is_instance_valid(GameState.Grass):
    # Backup modifier stack.
    if not GameState.Grass.modifier_stack.stack.empty() and ScatterModifierStackBackup.empty():
      for item in GameState.Grass.modifier_stack.stack:
        ScatterModifierStackBackup.append(item.duplicate())

    # Restore modifier stack.
    if GameState.Grass.modifier_stack.stack.empty() and not ScatterModifierStackBackup.empty():
      for item in ScatterModifierStackBackup:
        GameState.Grass.modifier_stack.stack.append(item)
    
    # Update grass.
    GameState.Grass.modifier_stack.stack[0].instance_count = GameState.initial_grass * multiplier
    GameState.Grass._do_update()
  
  Configuration.update_setting("graphics", "grass_amount", index)

func grass_index_to_multiplier(index: int):
  var multiplier = 1
  match index:
    0: # Maximum
      multiplier = 1
    1: # High
      multiplier = 0.75
    2: # Medium
      multiplier = 0.5
    3: # Low
      multiplier = 0.25
    4: # None
      multiplier = 0
  return multiplier

func change_map(map_name: String):
  GameState.MapName = map_name
  var map_file = "res://maps/%s.tscn" % map_name
  #Utils.exists(map_file) 
  if is_instance_valid($"/root/Main"): # Game started normally, use background loading.
    $"/root/Main".load_world(map_file)
  else: # Game started through "Play Scene" in editor.
    var _error = get_tree().change_scene(map_file)

func play_audio(stream):
  if !$Audio/AudioStreamPlayer1.playing:
    $Audio/AudioStreamPlayer1.stream = stream
    $Audio/AudioStreamPlayer1.play()
  elif !$Audio/AudioStreamPlayer2.playing:
    $Audio/AudioStreamPlayer2.stream = stream
    $Audio/AudioStreamPlayer2.play()
  elif !$Audio/AudioStreamPlayer3.playing:
    $Audio/AudioStreamPlayer3.stream = stream
    $Audio/AudioStreamPlayer3.play()
  elif !$Audio/AudioStreamPlayer4.playing:
    $Audio/AudioStreamPlayer4.stream = stream
    $Audio/AudioStreamPlayer4.play()
  elif !$Audio/AudioStreamPlayer5.playing:
    $Audio/AudioStreamPlayer5.stream = stream
    $Audio/AudioStreamPlayer5.play()
  else:
    print("Error: No AudioStreamPlayer was available to play sound.")

func reload_current_scene():
  var Main = get_node_or_null("/root/Main")
  if is_instance_valid(Main): # Game started normally, use background loading.
    var WorldScene = $"/root/Main/WorldScene"
    Main.load_world(WorldScene.get_child(0).filename)
  else: # Game started through "Play Scene" in editor.
    var _error = get_tree().reload_current_scene()
