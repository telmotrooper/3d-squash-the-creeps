extends Node

var main_scene = load("res://maps/TestMap.tscn")

func _on_NewGameButton_pressed():
  $AnimationPlayerMenu.play("menu_fade_out")

func _on_ExitButton_pressed():
  get_tree().quit()

func _on_AnimationPlayerMenu_animation_finished(_anim_name):
  GameState.change_map("TestMap")
