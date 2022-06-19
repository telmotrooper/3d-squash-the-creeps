extends Node

var Player: KinematicBody
var Grass: Node
var MapName: String
var UserInterface: Control
var RetryCamera: Camera # Camera to be used when player dies.

# Used to decide whether to play crash sound in Hub 1.
var new_game := true

var upgrades = {
  "double_jump": false,
  "mid_air_dash": false
}

var godot_heads_counter := 0
var total_godot_heads_in_map := 0

var godot_heads_collected = {
  "TestMap": {
    "FloatingGodotHead": false,
    "GrassGodotHead": false,
    "BeachGodotHead": false,
    "BridgeGodotHead": false
   },
  "MontainMap": {
    "GodotHead": false,
    "GodotHead2": false
   }
}

var global_progress = { "collected": 0, "total": 0, "percentage": 0.0 }
var progress = {}

var amount_of_gems := 0
var gems_collected = {}

var global_gem_progress = { "collected": 0, "total": 90+9, "percentage": 0.0 }
var gem_progress = {
  "TestMap": { "collected": 0, "total": 90, "percentage": 0.0 },
  "MontainMap": { "collected": 0, "total": 9, "percentage": 0.0 }
}

# Backup this value so it can be used to start a new game.
var initial_godot_heads_collected = var2bytes(godot_heads_collected)
var initial_gem_progress = var2bytes(gem_progress)
var initial_global_gem_progress = var2bytes(global_gem_progress)

func calculate_overall_progress(): # Currently gems and godot heads have the same weight.
  var collected = global_progress.collected + global_gem_progress.collected
  var total = global_progress.total + global_gem_progress.total
  return float(collected) / total

func collect_gem(map_name: String, path: NodePath):
  gems_collected[map_name][path].collected = true
  
  gem_progress[map_name].collected += gems_collected[map_name][path].value
  global_gem_progress.collected += gems_collected[map_name][path].value
  
  gem_progress[map_name].percentage = float(gem_progress[map_name].collected) / gem_progress[map_name].total
  global_gem_progress.percentage = float(global_gem_progress.collected) / global_gem_progress.total
  
  if gem_progress[map_name].percentage == 1.0:
    UserInterface.show_all_gems_collected()
  
  UserInterface.show_hud()
  amount_of_gems += gems_collected[map_name][path].value
  UserInterface.get_node("%GemLabel").text = "%d" % amount_of_gems
  generate_progress_report(map_name)

func initialize(): # Used in "New Game".
  new_game = true
  gems_collected = {}
  godot_heads_collected = bytes2var(initial_godot_heads_collected)
  gem_progress = bytes2var(initial_gem_progress)
  global_gem_progress = bytes2var(initial_global_gem_progress)
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
    text += map_name + ": \n"
    text += "%d/%d (%.2f%%)   \n" % [progress[map_name].collected, progress[map_name].total, progress[map_name].percentage * 100]
    
    text += "%d/%d (%.2f%%)   \n\n" % [gem_progress[map_name].collected, gem_progress[map_name].total, gem_progress[map_name].percentage * 100]
  
  var overall_progress = calculate_overall_progress()
  
  UserInterface.get_node("%ProgressButton").text = "Progress: %.2f%%" % [overall_progress * 100]
  UserInterface.get_node("%World1Progress").text = text
  
  if current_map and progress.has(current_map):
    UserInterface.get_node("%ScoreLabel").text = "%s / %s" % [progress[current_map].collected, progress[current_map].total]
  else:
    UserInterface.get_node("%ScoreLabel").text = "%s" % global_progress.collected

func collect_godot_head(map_name, id):
  UserInterface.show_hud()
  GameState.godot_heads_collected[map_name][id] = true
  
  # Update progress.
  progress[map_name].collected += 1
  global_progress.collected += 1
  
  progress[map_name].percentage = float(progress[map_name].collected) / progress[map_name].total
  global_progress.percentage = float(global_progress.collected) / global_progress.total
  
  if progress[map_name].percentage == 1.0:
    UserInterface.show_all_godot_heads_collected()
  
  generate_progress_report(map_name)

func register_godot_head(map_name, id):
  if not map_name in godot_heads_collected:
    print("Warning: Update GameState to include '%s'." % map_name)
    godot_heads_collected[map_name] = {}
  
  if not id in godot_heads_collected[map_name]:
    print("Warning: Update GameState to include '%s'." % id)
    GameState.godot_heads_collected[map_name][id] = false

func register_gem(map_name: String, path: NodePath, gem_value: int):
  if not map_name in gems_collected:
    gems_collected[map_name] = {}
  
  if not path in gems_collected[map_name]:
    gems_collected[map_name][path] = { "collected": false, "value": gem_value }

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

func play_music(stream):
  if $BGM.stream != stream:
    $BGM.stream = stream
    $BGM.play()
  elif not $BGM.playing:
    $BGM.play()

func stop_music():
  $BGM.stop()

func reload_current_scene():
  var Main = get_node_or_null("/root/Main")
  if is_instance_valid(Main): # Game started normally, use background loading.
    var WorldScene = $"/root/Main/WorldScene"
    Main.load_world(WorldScene.get_child(0).filename)
  else: # Game started through "Play Scene" in editor.
    var _error = get_tree().reload_current_scene()
