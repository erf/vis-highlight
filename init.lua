local M = {}

M.patterns = {}

-- TODO set for a spesific pattern
M.STYLE_ID = 0
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

function highlight(pattern, viewport, content)
	local offset = viewport.start
	for from, ends in match_iterator(pattern, content)
		local style_start  = from - 1 + offset
		local style_finish = ends - 1 + offset
		win:style(M.style and M.STYLE_ID or win.STYLE_CURSOR, start, finish)
		if ends >= viewport.finish then break end
	end
end

function on_win_highlight(win)
	local viewport = win.viewport
	local content = win.file:content(viewport)
	for pattern, enabled in pairs(M.patterns) do
		if enabled then
			highlight(pattern, viewport, content)
		end
	end
end

function on_win_open(win)
	if M.style then
		win:style_define(M.STYLE_ID, M.style)
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
	else
		vis:info('invalid arg')
		return
	end

	M.patterns[pattern_a] = enabled

	return true
end

function hi_ls_command()
	local t = {}
	table.insert(t, 'patterns:')
	for pattern, enabled in pairs(M.patterns) do
		table.insert(t, '\"' .. pattern .. '\" ' .. (enabled and 'on' or 'off'))
	end
	local s = table.concat(t, '\n')
	vis:message(s)
end

function hi_cl_command()
	M.patterns = {}
	vis:info 'cleared patterns'
end

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, on_win_highlight)

vis.events.subscribe(vis.events.WIN_OPEN, on_win_open)

vis:command_register('hi', hi_command)

vis:command_register('hi-ls', hi_ls_command)

vis:command_register('hi-cl', hi_cl_command)

return M
