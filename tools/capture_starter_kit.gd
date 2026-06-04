extends SceneTree

const STARTER_SCENE := preload("res://scenes/starter/StarterKitMain.tscn")
const BASE_DIR := "res://qa_artifacts/starter_kit"
const SCREENS := ["main_menu", "mode_select", "match", "result"]

var _captures: Array[Dictionary] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("starter_capture: begin")
	var sizes: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1920, 1080)]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(BASE_DIR))
	for size in sizes:
		var size_dir := "%s/%dx%d" % [BASE_DIR, size.x, size.y]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(size_dir))
		for screen in SCREENS:
			var rel_path := "%s/%s.png" % [size_dir, screen]
			await _capture_screen(screen, size, rel_path)
			_captures.append({
				"screen": screen,
				"resolution": "%dx%d" % [size.x, size.y],
				"path": rel_path
			})
	var manifest_path := "%s/screenshot_manifest.json" % BASE_DIR
	var manifest_file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if manifest_file != null:
		manifest_file.store_string(JSON.stringify({"captures": _captures}, "\t"))
		manifest_file.close()
	print("starter_capture: manifest=", ProjectSettings.globalize_path(manifest_path))
	print("starter_capture: pass")
	quit()

func _capture_screen(screen: String, size: Vector2i, rel_path: String) -> void:
	var viewport := SubViewport.new()
	viewport.size = size
	viewport.transparent_bg = false
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)
	var scene := STARTER_SCENE.instantiate()
	viewport.add_child(scene)
	scene.call("configure_for_capture", screen, size)
	for _frame in range(10):
		await process_frame
	var image := viewport.get_texture().get_image()
	var abs_path := ProjectSettings.globalize_path(rel_path)
	var save_error := image.save_png(abs_path)
	if save_error != OK:
		push_error("Failed to save screenshot: %s" % abs_path)
	else:
		print("starter_capture: saved=", abs_path)
	viewport.queue_free()
	await process_frame
