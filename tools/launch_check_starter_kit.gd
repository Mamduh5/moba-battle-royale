extends SceneTree

const STARTER_SCENE := preload("res://scenes/starter/StarterKitMain.tscn")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("starter_launch_check: begin")
	var scene := STARTER_SCENE.instantiate()
	get_root().add_child(scene)
	scene.call("configure_for_capture", "match", Vector2i(1280, 720))
	for frame in range(20):
		await process_frame
		if frame == 3:
			print("starter_launch_check: scene_draw_ready")
	var status: Dictionary = scene.call("get_starter_kit_status")
	print("starter_launch_check: status=", JSON.stringify(status))
	print("starter_launch_check: pass")
	quit()

