local M = {}

M.HIGHLIGHT_STYLE_ID = 0
M.patterns = {}
M.styleId = nil
M.style = nil

function match_iterator(pattern, content)
	local init = 1
	return function()
		local from, ends = string.find(content, pattern, init)
		if from == nil then return nil end
		init = ends + 1
		return from, ends
	end
end

function style(from, ends, offset, win)
	local start  = from - 1 + offset
	local finish = ends - 1 + offset
	win:style(M.styleId, start, finish)
end

function highlight(pattern, win, viewport, content)
	local offset = viewport.start
	for from, ends in match_iterator(pattern, content) do
		style(from, ends, offset, win)
		if ends >= viewport.finish then break end
	end
end

function on_win_highlight(win)
	if M.styleId == nil then return end
	local viewport = win.viewport
	local content = win.file:content(viewport)
	for pattern, enabled in pairs(M.patterns) do
		if enabled then
			highlight(pattern, win, viewport, content)
		end
	end
end

function on_win_open(win)
	if M.style then
		M.styleId = M.HIGHLIGHT_STYLE_ID
		win:style_define(M.styleId, M.style)
	else
		M.styleId = win.STYLE_CURSOR
	end
end

function hi_command(argv, force, win, selection, range)
	local pattern_a = argv[1]
	local enabled_a = argv[2]

	if not pattern_a then return end

	local enabled = true
	if enabled_a == nil or enabled_a == "on" then
		enabled = true
	elseif enabled_a == "off" then
		enabled = false
	end

	M.patterns[pattern_a] = enabled

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
end

function hi_cl_command(argv, force, win, selection, range)
	M.patterns = {}
	vis:info 'patterns cleared'
end

function hi_rm_command(argv, force, win, selection, range)
	local pattern_a = argv[1]
	if not pattern_a then return end
	M.patterns[pattern_a] = nil
	vis:info('pattern \"' .. pattern_a .. '\" removed')
	return true
end

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, on_win_highlight)

vis.events.subscribe(vis.events.WIN_OPEN, on_win_open)

vis:command_register('hi', hi_command)

vis:command_register('hi-ls', hi_ls_command)

vis:command_register('hi-cl', hi_cl_command)

vis:command_register('hi-rm', hi_rm_command)

return M
