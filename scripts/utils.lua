local function round(number)
	return math.floor(number + 0.5)
end

local function write(path, data, process)
	local handle = process and io.popen(path, "w") or io.open(path, "w")
	handle:write(data)
	handle:close()
end

local function xdg(var, fallback, name)
	return os.getenv(var) or (os.getenv("HOME") .. "/" .. fallback) .. "/" .. name
end

local function xdg_config(name)
	return xdg("XDG_CONFIG_HOME", ".config", name)
end

local function get_path()
	local path = mp.get_property_native("path")
	local time_pos = round(mp.get_property_native("time-pos"))

	if time_pos and time_pos > 0 then
		if path:find("https://www.youtube.com/watch?v=", 0, true) == 1 then
			path = path:gsub("&t=%d+", "") .. "&t=" .. time_pos
		elseif path:find("https://youtu.be/", 0, true) == 1 then
			path = path:gsub("?.*", "") .. "?t=" .. time_pos
		end
	end

	return path
end

mp.add_key_binding(nil, 'copy-path', function()
	local path = get_path()

	write([[xclip -selection clipboard]], path, true)
	mp.osd_message("Copied to clipboard: " .. path)
end)

mp.add_key_binding(nil, 'read-playlist', function()
	mp.commandv("loadfile", xdg_config("mpv") .. "/playlist.m3u")
end)

mp.add_key_binding(nil, 'write-playlist', function()
	local playlist = mp.get_property_native("playlist")

	local text = "#EXTM3U"

	for _, item in ipairs(playlist) do
		text = text .. "\n#EXTINF:-1," .. (item.title or item.filename) .. "\n" .. item.filename
	end

	write(xdg_config("mpv") .. "/playlist.m3u", text)
	mp.osd_message("Playlist saved")
end)

mp.add_key_binding(nil, 'xdg-open', function()
	write([[sh -c 'xdg-open "$(cat -)"']], get_path(), true)
end)
