local M = {}

M.patterns = {}

function highlight(pattern, win)

	-- search through visible area to highlight patterns
	local viewport = win.viewport
	local content = win.file:content(viewport)
	local offset = viewport.start
	local search_from = 0

	while true do
		-- note: string.find() returns 1-based index, not 0-based
		local from, to = string.find(content, pattern, search_from)

		-- stop searching if no more matches found
		if from == nil then break end

		-- mark
		-- convert from 1-based index to 0-based
		-- also add the offset
		local mark_from = from - 1 + offset
		local mark_to = to - 1 + offset
		win:style(win.STYLE_CURSOR, mark_from, mark_to)

		-- start next search after the current match
		search_from = to + 1
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
	vis:info 'patterns cleared'
end

vis:command_register('hi', hi_command)

vis:command_register('hi-ls', hi_ls_command)

vis:command_register('hi-cl', hi_cl_command)

return M
