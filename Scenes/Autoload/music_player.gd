extends Node

@export var fade_time_sec = 1

@onready var bee_battle_player = $BeeBattlePlayer
@onready var zombee_birth_player = $ZombeeBirthPlayer

@onready var tween = get_tree().create_tween()

func _ready():
	play_zombee_birth()

func play_bee_battle():
	if zombee_birth_player.playing:
		if tween != null:
			tween.kill()
		tween = get_tree().create_tween()
		await tween.tween_property(zombee_birth_player, "volume_db", -80, fade_time_sec).finished
		zombee_birth_player.stop()
	bee_battle_player.volume_db = 0
	bee_battle_player.play()

func play_zombee_birth():
	if bee_battle_player.playing:
		if tween != null:
			tween.kill()
		tween = get_tree().create_tween()
		await tween.tween_property(bee_battle_player, "volume_db", -80, fade_time_sec).finished
		bee_battle_player.stop()
	zombee_birth_player.volume_db = 0
	zombee_birth_player.play()

func toggle_muffle():
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("MuffleBus"), 0, !AudioServer.is_bus_effect_enabled(AudioServer.get_bus_index("MuffleBus"), 0))
