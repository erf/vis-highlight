local M = {}

M.patterns = {}

-- TODO set for a spesific pattern
M.STYLE_ID = 0
M.style = nil

function style(from, ends, viewport)
	local style_start  = from - 1 + viewport.start
	local style_finish = ends - 1 + viewport.start
	if M.style then
		win:style(M.STYLE_ID, style_start, style_finish)
	else
		win:style(win.STYLE_CURSOR, style_start, style_finish)
	end
end

function match(pattern, init, viewport, content)
	local from, ends = string.find(content, pattern, init)
	if from == nil then return viewport.finish end
	style(from, ends, viewport)
	return ends + 1
end

function highlight(pattern, viewport, content)
	local init = 1
	while init < viewport.finish do
		init = match(pattern, init, viewport, content)
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

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, on_win_highlight)

function on_win_open(win)
	if M.style then
		win:style_define(M.STYLE_ID, M.style)
	end
end

vis.events.subscribe(vis.events.WIN_OPEN, on_win_open)

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

vis:command_register('hi', hi_command)

vis:command_register('hi-ls', hi_ls_command)

vis:command_register('hi-cl', hi_cl_command)

return M
