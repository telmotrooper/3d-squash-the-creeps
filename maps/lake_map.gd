extends Node3D

@export var map_music: AudioStream
@export var drain_water_sound: AudioStream
@export var minimap: Texture2D

func _ready() -> void:
	GameState.UserInterface.set_minimap(minimap, Vector2(-100,-75), 1.72)
	GameState.play_music(map_music)

func _on_RedButton_pressed() -> void:
	$AnimationPlayer.play("drain_water")

func _on_Player_hit() -> void:
	GameState.UserInterface.retry()

func emit_particles(value: bool) -> void:
	%TunnelFloatingParticles.emitting = value
	%TunnelFloatingParticles.show()

func _on_AreaToStartParticles_body_entered(_body: Node) -> void:
	emit_particles(true)

func _on_AreaToStopParticles_body_entered(player: Node) -> void:
	if player.is_on_floor():
		emit_particles(false)

func _on_AreaToStopParticles_body_exited(player: Node) -> void:
	if player.is_on_floor():
		emit_particles(false)

func _on_AreaToMakePlayerFloat_body_entered(_body: Node) -> void:
	if %TunnelFloatingParticles.emitting:
		GameState.Player.floating = true

func _on_AreaToMakePlayerFloat_body_exited(_body: Node) -> void:
	GameState.Player.floating = false
