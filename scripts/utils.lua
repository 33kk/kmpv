local function round(number)
	return math.floor(number + 0.5)
end

local function execute_write(command, data)
	local process = io.popen(command, "w")
	process:write(data)
	process:close()
end

local function get_path()
	local path = mp.get_property_native("path")
	local time_pos = round(mp.get_property_native("time-pos"))

	if time_pos and time_pos > 0 and path:find("https://www.youtube.com/watch?v=", 0, true) == 1 then
		path = path:gsub("&t=%d+", "") .. "&t=" .. time_pos
	end

	return path
end

mp.add_key_binding(nil, 'copy-path', function()
	local path = get_path()

	execute_write([[xclip -selection clipboard]], path)
	mp.osd_message("Copied to clipboard: " .. path)
end)

mp.add_key_binding(nil, 'xdg-open', function()
	execute_write([[sh -c 'xdg-open "$(cat -)"']], get_path())
end)
