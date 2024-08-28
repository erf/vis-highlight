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

-- e.g. pattern = 'foo'
local valid_pattern = function(pattern)
	if not pattern then
		return false
	end
	local ok, result, finish = pcall(string.find, '', pattern)
	if not ok then
		return false
	end
	return true
end

-- e.g. style = 'fore:red,back:blue,bold'
local valid_style = function(style)
	-- TODO improve style validation
	if not style then
		return false
	end
	return true
end

local on_win_highlight = function(win)
	local content = win.file:content(win.viewport.bytes)
	for pattern, data in pairs(M.patterns) do

		if data.hideOnInsert and vis.mode == vis.modes.INSERT then
			goto continue
		end

		for from, ends in pattern_iterator(pattern, content) do
			local offset = win.viewport.bytes.start
			local start  = from - 1 + offset
			local finish = ends - 1 + offset
			if not data.style then
				win:style(win.STYLE_CURSOR, start, finish)
			else 
				win:style(data.styleId, start, finish)
			end
            if ends >= win.viewport.bytes.finish then break end
        end

		::continue::
	end
end

local define_styles_for_all_windows = function()
    for pattern, data in pairs(M.patterns) do
		if not data.style then
			goto continue
		end

        if not data.styleId then
            data.styleId = table.remove(styleIdStack, 1)
	        table.insert(styleIdStack, data.styleId)
        end

        for win in vis:windows() do
            if win:style_define(data.styleId, data.style) then
                -- SUCCESS
            end
        end
		
		::continue::
    end
end

local on_win_open = function(win)
    define_styles_for_all_windows()
end

local hi_command = function(argv, force, win, selection, range)
	local pattern = argv[1]
	local style = argv[2]
	if not valid_pattern(pattern) then
		vis:info('invalid pattern')
		return
	end
	if not valid_style(style) then
		-- vis:info('missing style - e.g. fore:red,back:blue,bold')
		-- return
		-- let's just use default style win.STYLE_CURSOR
	end
	M.patterns[pattern] = { style = style }
	define_styles_for_all_windows()
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

local hi_clear_command = function(argv, force, win, selection, range)
	M.patterns = {}
	initStyleIds()
	vis:info 'cleared all patterns'
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

vis:command_register('hi-clear', hi_clear_command)

vis:command_register('hi-rm', hi_rm_command)

return M
