extends Node

export (Environment) var day_environment
export (Environment) var night_environment
export (AudioStream) var map_music

func _ready():
  GameState.stop_music()
  if GameState.new_game:
    $WorldEnvironment.environment = night_environment
    $AudioStreamPlayer.play() # Crash sound.
    GameState.new_game = false
  else:
    $WorldEnvironment.environment = day_environment
    GameState.play_music(map_music)
    $Spaceship/Smoke.queue_free()
  
  GameState.RetryCamera = $RetryCamera

func _on_Player_hit():
  GameState.UserInterface.retry()

func _on_AudioStreamPlayer_finished():
  GameState.play_music(map_music)
