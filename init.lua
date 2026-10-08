local M = {}

M.patterns = {}

-- style ids allocated with vis.ui:style_push(), kept for reuse when patterns are removed
local freeStyleIds = {}

local acquire_style_id = function()
	return table.remove(freeStyleIds) or vis.ui:style_push()
end

local release_style_id = function(styleId)
	if styleId then table.insert(freeStyleIds, styleId) end
end

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
			local start = from - 1 + offset
			local finish = ends - 1 + offset
			if not data.style then
				win:style(vis.ui.style_ids.CURSOR, start, finish)
			else 
				win:style(data.styleId, start, finish)
			end
			if ends >= win.viewport.bytes.finish then 
				break 
			end
		end

		::continue::
	end
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
		-- let's just use default style vis.ui.style_ids.CURSOR
	end
	local old = M.patterns[pattern]
	local data = { style = style }
	if style then
		data.styleId = (old and old.styleId) or acquire_style_id()
		vis.ui:style_define(data.styleId, style)
	elseif old then
		release_style_id(old.styleId)
	end
	M.patterns[pattern] = data
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
	for _, data in pairs(M.patterns) do
		release_style_id(data.styleId)
	end
	M.patterns = {}
	vis:info 'cleared all patterns'
	return true
end

local hi_rm_command = function(argv, force, win, selection, range)
	local pattern = argv[1]
	if not pattern then return end
	local data = M.patterns[pattern]
	if data then
		-- return styleId for reuse
		release_style_id(data.styleId)
	end
	M.patterns[pattern] = nil
	vis:info('pattern \"' .. pattern .. '\" removed')
	return true
end

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, on_win_highlight)

vis:command_register('hi', hi_command)

vis:command_register('hi-ls', hi_ls_command)

vis:command_register('hi-clear', hi_clear_command)

vis:command_register('hi-rm', hi_rm_command)

return M
