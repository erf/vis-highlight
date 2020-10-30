local M = {}

M.patterns = {}

local nextId = 16

function match_iterator(pattern, content)
	local init = 1
	return function()
		local from, ends = string.find(content, pattern, init)
		if from == nil then return nil end
		init = ends + 1
		return from, ends
	end
end

function style(from, ends, offset, win, data)
	local start  = from - 1 + offset
	local finish = ends - 1 + offset
	if data and data.id then
		win:style(data.id, start, finish)
	else
		win:style(win.STYLE_CURSOR, start, finish)
	end
end

function highlight(pattern, data, win, viewport, content)
	local offset = viewport.start
	for from, ends in match_iterator(pattern, content) do
		style(from, ends, offset, win, data)
		if ends >= viewport.finish then break end
	end
end

function next_style_id()
	--[[
	-- TODO find next minimal int in list of ids
	local ids = {}
	for pattern, data in pairs(M.patterns) do
		if data and data.id then
			ids[id] = data.id
		end
	end
	table.sort(ids)
	--]]

	nextId = nextId + 1

	return nextId
end

function on_win_highlight(win)
	local viewport = win.viewport
	local content = win.file:content(viewport)
	for pattern, data in pairs(M.patterns) do
		highlight(pattern, data, win, viewport, content)
	end
end

-- highlight a given Lua pattern with an optional style
function hi_command(argv, force, win, selection, range)
	local pattern = argv[1]
	local style   = argv[2]

	if not pattern then return end

	if style then
		local id = next_style_id()
		if win:style_define(id, style) then
			M.patterns[pattern] = { style = style, id = id }
		else
			M.patterns[pattern] = {}
		end
	else
		M.patterns[pattern] = {}
	end

	return true
end

-- list patterns
function hi_ls_command(argv, force, win, selection, range)
	local t = {}
	table.insert(t, 'patterns:')
	for pattern, data in pairs(M.patterns) do
		local str_esc = pattern:gsub('\n', '\\n')
		local stl = ''
		if data and data.style then stl = data.style end
		table.insert(t, '\'' .. str_esc .. '\' - ' .. stl)
	end
	local s = table.concat(t, '\n')
	vis:message(s)
end

-- clear all patterns
function hi_cl_command(argv, force, win, selection, range)
	M.patterns = {}
	vis:info 'patterns cleared'
end

-- remove spesific pattern
function hi_rm_command(argv, force, win, selection, range)
	local pattern = argv[1]
	if not pattern then return end
	M.patterns[pattern] = nil
	vis:info('pattern \"' .. pattern .. '\" removed')
	return true
end

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, on_win_highlight)

vis:command_register('hi', hi_command)

vis:command_register('hi-ls', hi_ls_command)

vis:command_register('hi-cl', hi_cl_command)

vis:command_register('hi-rm', hi_rm_command)

return M
