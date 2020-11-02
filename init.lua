local M = {}

M.patterns = {}
M.style = nil
M.CUSTOM_STYLE_ID = 64
local styleId = nil

function pattern_iterator(pattern, content)
	local init = 1
	return function()
		local from, ends = string.find(content, pattern, init)
		if from == nil then return nil end
		init = ends + 1
		return from, ends
	end
end

function set_style(from, ends, win)
	local offset = win.viewport.start
	local start  = from - 1 + offset
	local finish = ends - 1 + offset
	win:style(styleId, start, finish)
end

function highlight(pattern, win, content)
	for from, ends in pattern_iterator(pattern, content) do
		set_style(from, ends, win)
		if ends >= win.viewport.finish then break end
	end
end

function on_win_highlight(win)
	if not styleId then return end
	local content = win.file:content(win.viewport)
	for pattern, enabled in pairs(M.patterns) do
		if enabled then highlight(pattern, win, content) end
	end
end

function on_win_open(win)
	styleId = win.STYLE_CURSOR
	if M.style then
		styleId = M.CUSTOM_STYLE_ID
		win:style_define(styleId, M.style)
	end
end

function is_enabled(enabled)
	if enabled == nil or enabled == "on" then return true
	elseif enabled == "off" then return false
	else return true end
end

function valid(pattern)

	if not pattern then
		vis:info('missing pattern')
		return false
	end

	local ok, result, finish = pcall(string.find, '', pattern)

	if not ok then
		if result then
			vis:info('invalid pattern: ' .. result)
		else
			vis:info('invalid pattern')
		end
		return false
	end
	
	if result and finish and finish < result  then
		vis:info('invalid range from ' .. result .. ' finish ' .. finish)
		return false
	end

	return true
end

function hi_command(argv, force, win, selection, range)
	local pattern = argv[1]
	local enabled = argv[2]
	if not valid(pattern) then return end
	M.patterns[pattern] = is_enabled(enabled)
	return true
end

function hi_ls_command(argv, force, win, selection, range)
	local t = {}
	table.insert(t, 'patterns:')
	for pattern, enabled in pairs(M.patterns) do
		local str_esc = pattern:gsub('\n', '\\n')
		table.insert(t, '\"' .. str_esc .. '\" ' .. (enabled and 'on' or 'off'))
	end
	local s = table.concat(t, '\n')
	vis:message(s)
	return true
end

function hi_cl_command(argv, force, win, selection, range)
	M.patterns = {}
	vis:info 'patterns cleared'
	return true
end

function hi_rm_command(argv, force, win, selection, range)
	local pattern = argv[1]
	if not pattern then return end
	M.patterns[pattern] = nil
	vis:info('pattern \"' .. pattern .. '\" removed')
	return true
end

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, on_win_highlight)

vis.events.subscribe(vis.events.WIN_OPEN, on_win_open)

vis:command_register('hi', hi_command)

vis:command_register('hi-ls', hi_ls_command)

vis:command_register('hi-cl', hi_cl_command)

vis:command_register('hi-rm', hi_rm_command)

return M
