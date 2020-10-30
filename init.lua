local M = {}

M.patterns = {}
M.style = "" -- TOOD

-- highlight patterns in visible area
function highlight(pattern, win)

	local viewport = win.viewport
	local content = win.file:content(viewport)
	local init = 1

	while init < viewport.finish do

		local from, ends = string.find(content, pattern, init)

		if from == nil then break end

		local style_start  = from - 1 + viewport.start
		local style_finish = ends - 1 + viewport.start
		win:style(win.STYLE_CURSOR, style_start, style_finish)

		init = ends + 1
	end
end

function on_win_highlight(win)
	for pattern, enabled in pairs(M.patterns) do
		if enabled then
			highlight(pattern, win)
		end
	end
end

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, on_win_highlight)

function hi_command(argv, force, win, selection, range)
	local pattern_arg = argv[1]
	local enabled_arg = argv[2]

	if not pattern_arg then 
		return
	end 

	local enabled
	if enabled_arg == nil or enabled_arg == "on" then
		enabled = true
	elseif enabled_arg == "off" then
		enabled = false
	else
		vis:info('invalid arg')
		return
	end

	M.patterns[pattern_arg] = enabled

	return true
end

function hi_ls_command()
	local t = {}
	table.insert(t, 'patterns:')
	for pattern, enabled in pairs(M.patterns) do
		table.insert(t, pattern .. ' ' .. (enabled and 'on' or 'off'))
	end
	local s = table.concat(t, '\n')
	vis:message(s)
end

function hi_cl_command()
	M.patterns = {}
	vis:info 'cleared'
end

vis:command_register('hi', hi_command)

vis:command_register('hi-ls', hi_ls_command)

vis:command_register('hi-cl', hi_cl_command)

return M
