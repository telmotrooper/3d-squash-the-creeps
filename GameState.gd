extends Node

var Audio: Node
var Player: Node
var Grass: Node

const initial_grass = 4000

func update_grass(index: int = -1):
  if index == -1: # If called with no index, set the one from the configuration file.
    index = Configuration.get_value("graphics", "grass_amount")
    
  var multiplier = grass_index_to_multiplier(index)
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
    4: # Very Low
      multiplier = 0.1
    5: # None
      multiplier = 0
  return multiplier
