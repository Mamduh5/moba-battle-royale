class_name RenderedUiAuditCommand
extends RefCounted

const SCREENS := [
	"main_menu",
	"mode_select",
	"3v3_hud_mid_match",
	"3v3_result",
	"deathmatch_hud_mid_match",
	"deathmatch_result",
]

func run_async(_options: Dictionary, tree: SceneTree) -> int:
	var errors: Array[String] = []
	var artifacts: Array[String] = []
	for size in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		for screen in SCREENS:
			var path := "res://qa_artifacts/rendered_ui/%dx%d/%s.png" % [size.x, size.y, screen]
			var ok := await _capture(tree, size, screen, path)
			if ok:
				artifacts.append(path)
			else:
				errors.append("failed to capture %s" % path)
	if not errors.is_empty():
		print(JSON.stringify({"cmd": "rendered-ui-audit", "status": "fail", "errors": errors, "artifacts": artifacts}))
		return 1
	print(JSON.stringify({"cmd": "rendered-ui-audit", "status": "pass", "artifacts": artifacts, "screens": SCREENS, "resolutions": ["1280x720", "1920x1080"]}))
	return 0

func _capture(tree: SceneTree, viewport_size: Vector2i, screen: String, res_path: String) -> bool:
	var viewport := SubViewport.new()
	viewport.size = viewport_size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = false
	tree.root.add_child(viewport)
	var painter := QaScreenPainter.new()
	painter.screen_id = screen
	viewport.add_child(painter)
	painter.position = Vector2.ZERO
	painter.anchor_left = 0.0
	painter.anchor_top = 0.0
	painter.anchor_right = 0.0
	painter.anchor_bottom = 0.0
	painter.offset_left = 0.0
	painter.offset_top = 0.0
	painter.offset_right = float(viewport_size.x)
	painter.offset_bottom = float(viewport_size.y)
	painter.size = Vector2(float(viewport_size.x), float(viewport_size.y))
	painter.queue_redraw()
	await tree.process_frame
	await tree.process_frame
	var image := viewport.get_texture().get_image()
	var dir := res_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var err := image.save_png(res_path)
	viewport.queue_free()
	return err == OK
