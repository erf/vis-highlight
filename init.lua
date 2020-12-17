local M = {}

M.patterns = {}

local styleIdStack = {}

local styleIdIterator = function()
	local i = 0
	local MAX_STYLE_ID = 64
	return function()
		i = i + 1
		if i <= MAX_STYLE_ID then return i end
		return nil
	end
end

local initStyleIds = function()
	styleIdStack = {}
	for i in styleIdIterator() do
		table.insert(styleIdStack, i)
	end
end

initStyleIds()

local pattern_iterator = function(pattern, content)
	local init = 1
	return function()
		local from, ends = string.find(content, pattern, init)
		if from == nil then return nil end
		init = ends + 1
		return from, ends
	end
end

local set_style = function(from, ends, win, styleId)
	local offset = win.viewport.start
	local start  = from - 1 + offset
	local finish = ends - 1 + offset
	win:style(styleId, start, finish)
end

local highlight = function(pattern, styleId, win, content)
	for from, ends in pattern_iterator(pattern, content) do
		set_style(from, ends, win, styleId)
		if ends >= win.viewport.finish then break end
	end
end

local valid_pattern = function(pattern)

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

local valid_style = function(style)
	-- TODO improve style validation
	if style then
		return true
	end
	return false
end

local create_data = function(data, win)
	local style = data.style
	local hideOnInsert = data.hideOnInsert

	local id = table.remove(styleIdStack)
	if valid_style(style) and win:style_define(id, style) then
		return { styleId = id, style = style, hideOnInsert = hideOnInsert }
	end
	table.insert(styleIdStack, id)

	return { styleId = win.STYLE_CURSOR, hideOnInsert = hideOnInsert }
end

local on_win_highlight = function(win)
	local content = win.file:content(win.viewport)
	for pattern, data in pairs(M.patterns) do
		if data.hideOnInsert and vis.mode == vis.modes.INSERT then
			-- DO NOTHING
		elseif data.styleId then
			highlight(pattern, data.styleId, win, content)
		end
	end
end

local on_win_open = function(win)
	for pattern, data in pairs(M.patterns) do
		if not data.styleId then
			M.patterns[pattern] = create_data(data, win)
		end
	end
end

local hi_command = function(argv, force, win, selection, range)
	local pattern = argv[1]
	local style = argv[2]
	if not valid_pattern(pattern) then return end
	local data = { style = style }
	M.patterns[pattern] = create_data(data, win)
	return true
end

local hi_ls_command = function(argv, force, win, selection, range)
	local t = {}
	table.insert(t, 'patterns:')
	for pattern, data in pairs(M.patterns) do
		local pattern_escaped = pattern:gsub('\n', '\\n')
		local style_str = ''
		if data.style then
			style_str = data.style
		elseif data.styleId then
			style_str = 'id ' .. data.styleId
		end
		table.insert(t, '\'' .. pattern_escaped .. '\' - ' .. style_str)
	end
	local s = table.concat(t, '\n')
	vis:message(s)
	return true
end

local hi_cl_command = function(argv, force, win, selection, range)
	M.patterns = {}
	initStyleIds()
	vis:info 'patterns cleared'
	return true
end

local hi_rm_command = function(argv, force, win, selection, range)
	local pattern = argv[1]
	if not pattern then return end
	local data = M.patterns[pattern]
	if data and data.styleId and data.styleId ~= win.STYLE_CURSOR then
		-- return styleId for reuse
		table.insert(styleIdStack, data.styleId)
	end
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
