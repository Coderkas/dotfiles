local function print_window_event(w, ev)
	local log_file = io.open("/tmp/hypr_events.log", "a+")
	local log_string = string.format(
		"[%s]\nClass: %s\nInitial Class: %s\nTitle: %s\nInitial Title: %s\nContent: %s\nFloating: %s\nFullscreen: %s\nFullscreen (Client): %s\n\n\n",
		ev, w.class, w.initial_class, w.title, w.initial_title, w.content_type, w.floating, w.fullscreen,
		w.fullscreen_client)
	local ff, ff_msg, ff_code, num_b = log_file:write(log_string)
	log_file:close()

	if ff == nil then
		log_string = string.format("notify send 'Failed with msg %q and code %s'", ff_msg, ff_code)
		hl.exec_cmd(log_string)
	end
end

hl.on("window.update_rules", function (w) print_window_event(w, "Updated rules") end)
hl.on("window.class",        function (w) print_window_event(w, "Class changed") end)
hl.on("window.title",        function (w) print_window_event(w, "Title changed") end)
