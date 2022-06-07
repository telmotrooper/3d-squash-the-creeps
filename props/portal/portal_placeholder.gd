extends CSGCylinder

export var map_name: String
export var godot_heads_required: int

func _ready():
  $Label3D.text = map_name
  
  if godot_heads_required > 1:
    $RequirementLabel.text = "%d Godot Heads required" % godot_heads_required
  elif godot_heads_required == 1:
    $RequirementLabel.text = "%d Godot Head required" % godot_heads_required
  else:
    $RequirementLabel.text = ""

func _on_Portal_entered(_body):
  if GameState.global_progress.collected >= godot_heads_required:
    $AnimationPlayer.play("shrink")
    $RequirementLabel.visible = false
    #$AudioStreamPlayer.play()
    GameState.Player.get_node("EffectsAnimationPlayer").play("shrink")
    GameState.change_map(map_name)
