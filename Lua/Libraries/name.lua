local lib = {}
lib.interactable = {}
lib.initialised = false
lib.currentRow = 1
lib.currentCol = 1
lib.currentSet = 1
lib.name = ""

-- Characters used by each set
-- Number of entries dictates the number of charsets
-- There must be at least one charset
lib.charsets = {
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ",
	"abcdefghijklmnopqrstuvwxyz"
}

-- Number of columns per charset
-- Default: 7
lib.columns = 7

-- Spacing between columns
-- If -1, will auto-calculate to fit in the original bounds
-- Default: 64
lib.columnSpacing = -1

-- Spacing between each charset's rows
-- If -1, will auto-calculate to fit in the original bounds
-- Number of entries must be equal to the number of charsets
lib.rowSpacings = {
	-1,
	-1
}

-- The layer at which to place the name menu
-- Default: "Top"
lib.layer = "Top"

-- Whether to automatically hide the battle behind a black, fullscreen sprite
-- Default: true
lib.hideBattle = true

-- What music to change to
-- f left empty, will not change the music
-- Default: ""
lib.newMusic = ""

-- Color of unselected buttons (0-1)
-- Default: {1, 1, 1}
lib.unselectedColor = {1, 1, 1}

-- Color of selected buttons (0-1)
-- Default: {1, 1, 0}
lib.selectedColor = {1, 1, 0}

-- Maximum name length
-- Cannot exceed 9 (CYF limit)
-- Default: 9
lib.maxNameLength = 9

local function WhiteText(center, text, ...)
	local t = CreateText("", ...)
	t.color = {1, 1, 1}
	t.HideBubble()
	t.SetFont("uidialog")
	t.linePrefix = "[instant][effect:none]"
	t.SetText(text)
	t.progressmode = "none"
	if center then
		t.x = t.x - t.GetTextWidth()/2
	end
	return t
end

local function CreateCharset(result, charset, yoff, spacing)
	local cols = lib.columns
	local rows = lib.GetRows(charset)
	for i = 1, rows do
		for j = 1, cols do
			local idx = lib.GetIndex(i, j)
			result[idx] = WhiteText(true, "[effect:shake, 0.6]" .. charset:sub(idx, idx), {320 + (j - cols/2 - 0.5) * lib.columnSpacing, 304 + yoff - (i - 1) * spacing}, 640, lib.layer)
		end
	end
end

local function RecursiveDestruction(t)
	for k, v in pairs(t) do
		if type(v) == "table" then
			RecursiveDestruction(v)
		else
			v.Remove()
		end
	end
end

-- Must be called once, before Update(), to initialise the name menu
function lib.Start()
	State("NONE")
	lib.initialised = true
	lib.name = ""
	lib.maxNameLength = math.min(lib.maxNameLength, 9)

	local successful, spr = pcall(CreateSprite, "black", lib.layer)
	if not successful then
		error("'" .. lib.layer .. "' is not a valid layer!", 2)
	end

	if #lib.charsets < 1 then
		error("There must be at least one charset!", 2)
	end

	if #lib.rowSpacings ~= #lib.charsets then
		error("Number of entries in rowSpacings (" .. #lib.rowSpacings .. ") must be equal to the number of entries in charsets (" .. #lib.charsets .. ")!", 2)
	end

	if not lib.hideBattle then
		spr.Remove()
	end

	if lib.newMusic ~= "" then
		Audio.LoadFile(lib.newMusic)
	end

	if lib.columnSpacing == -1 then
		lib.columnSpacing = 448 / lib.columns
	end

	for i = 1, #lib.charsets do
		if lib.rowSpacings[i] == -1 then
			lib.rowSpacings[i] = 224 / lib.GetRows(lib.charsets[i]) / #lib.charsets
		end
	end

	lib.interactable.label = WhiteText(true, "[charspacing:2]Name the fallen human.", {320, 394}, 640, lib.layer)

	local yoff = 0
	lib.interactable.charsets = {}
	lib.interactable.charsets[1] = {}
	CreateCharset(lib.interactable.charsets[1], lib.charsets[1], 0, lib.rowSpacings[1])
	for i = 2, #lib.charsets do
		yoff = yoff - lib.rowSpacings[i-1] * lib.GetRows(lib.charsets[i-1]) - 8
		lib.interactable.charsets[i] = {}
		CreateCharset(lib.interactable.charsets[i], lib.charsets[i], yoff, lib.rowSpacings[i])
	end

	lib.interactable.name = WhiteText(false, "", {278, 346}, 640, lib.layer)
	lib.interactable.quit = WhiteText(true, "Quit", {146, 54}, 640, lib.layer)
	lib.interactable.backspace = WhiteText(true, "Backspace", {300, 54}, 640, lib.layer)
	lib.interactable.done = WhiteText(true, "Done", {466, 54}, 640, lib.layer)

	lib.Select(1, 1, 1)
end

function lib.GetLastRowColCount(set)
	return #lib.charsets[set] - (lib.GetRows(lib.charsets[set]) - 1) * lib.columns
end

function lib.GetRows(charset)
	return math.ceil(#charset / lib.columns)
end

function lib.GetIndex(row, col)
	return (row - 1) * lib.columns + col
end

function lib.ColorCharacter(set, row, col, color)
	lib.interactable.charsets[set][lib.GetIndex(row, col)].color = color
end

function lib.ColorButton(idx, color)
	if idx == 1 then
		lib.interactable.quit.color = color
	elseif idx == 2 then
		lib.interactable.backspace.color = color
	elseif idx == 3 then
		lib.interactable.done.color = color
	end
end

function lib.SelectButton(idx)
	if lib.currentRow ~= -1 then
		lib.ColorCharacter(lib.currentSet, lib.currentRow, lib.currentCol, lib.unselectedColor)
	end
	lib.ColorButton(lib.currentCol, lib.unselectedColor)
	lib.currentRow = -1
	lib.currentCol = idx
	lib.ColorButton(lib.currentCol, lib.selectedColor)
end

function lib.Select(set, row, col)
	lib.ColorCharacter(lib.currentSet, lib.currentRow, lib.currentCol, lib.unselectedColor)
	lib.currentSet = set
	lib.currentRow = row
	lib.currentCol = col
	lib.ColorCharacter(lib.currentSet, lib.currentRow, lib.currentCol, lib.selectedColor)
end

function lib.MoveSelection(dr, dc)
	local rows = lib.GetRows(lib.charsets[lib.currentSet])
	local charcount = #lib.charsets[lib.currentSet]
	local newrow = lib.currentRow + dr
	local newcol = lib.currentCol + dc
	if newcol == 0 then
		newrow = newrow - 1
		newcol = lib.columns
	elseif newcol > lib.columns then
		newrow = newrow + 1
		newcol = 1
	end
	local newidx = lib.GetIndex(newrow, newcol)
	if newidx > charcount then
		if lib.currentSet < #lib.charsets then
			if lib.currentRow == rows - 1 or newrow == rows + 1 then
				lib.Select(lib.currentSet + 1, 1, newcol)
			else
				lib.Select(lib.currentSet + 1, 1, 1)
			end
		else
			lib.SelectButton(2)
		end
	elseif newidx < 1 then
		if lib.currentSet > 1 then
			local cnt = lib.GetLastRowColCount(lib.currentSet)
			if dr == -1 and newcol >= cnt then
				lib.Select(lib.currentSet - 1, lib.GetRows(lib.charsets[lib.currentSet - 1]) - 1, newcol)
			else
				lib.Select(lib.currentSet - 1, lib.GetRows(lib.charsets[lib.currentSet - 1]), math.min(newcol, cnt))
			end
		else
			lib.SelectButton(2)
		end
	else
		lib.Select(lib.currentSet, newrow, newcol)
	end
end

function lib.MoveButtonSelection(delta)
	local newcol = lib.currentCol + delta
	if newcol == 0 then
		newcol = 3
	elseif newcol > 3 then
		newcol = 1
	end
	lib.SelectButton(newcol)
end

-- Must be called every frame, after Start()
function lib.Update()
	if not lib.initialised then
		error("Initialise the library with Start() before calling Update()!", 2)
	end

	if lib.currentRow == -1 then
		if Input.Confirm == 1 then
			if lib.currentCol == 1 then
				lib.OnQuit()
			elseif lib.currentCol == 2 then
				lib.OnBackspaceInput()
			elseif lib.currentCol == 3 then
				lib.OnNameConfirm()
			end
		end

		if Input.Left == 1 then
			lib.MoveButtonSelection(-1)
		elseif Input.Right == 1 then
			lib.MoveButtonSelection(1)
		elseif Input.Up == 1 then
			lib.currentRow = 1
			lib.ColorButton(lib.currentCol, lib.unselectedColor)
			lib.Select(#lib.charsets, lib.GetRows(lib.charsets[lib.currentSet]), lib.GetLastRowColCount(lib.currentSet))
		elseif Input.Down == 1 then
			lib.currentRow = 1
			lib.ColorButton(lib.currentCol, lib.unselectedColor)
			lib.Select(1, 1, 1)
		end
	else
		if Input.Confirm == 1 then
			local i = lib.GetIndex(lib.currentRow, lib.currentCol)
			lib.OnCharacterInput(lib.charsets[lib.currentSet]:sub(i, i))
		elseif Input.Cancel == 1 then
			lib.OnBackspaceInput()
		end

		if Input.Right == 1 then
			lib.MoveSelection(0, 1)
		elseif Input.Left == 1 then
			lib.MoveSelection(0, -1)
		elseif Input.Down == 1 then
			lib.MoveSelection(1, 0)
		elseif Input.Up == 1 then
			lib.MoveSelection(-1, 0)
		end
	end
end

function lib.SetName(name)
	lib.name = name
	lib.interactable.name.SetText(name)
end

function lib.OnCharacterInput(char)
	if #lib.name >= lib.maxNameLength then
		return
	end

	lib.SetName(lib.name .. char)
end

function lib.OnBackspaceInput()
	lib.SetName(lib.name:sub(1, -2))
end

function lib.OnQuit()
	lib.Destroy()
	State("DONE")
end

function lib.OnNameConfirm()
end

-- Remove all objects used by the library
function lib.Destroy()
	RecursiveDestruction(lib.interactable)
	lib.interactable = {}
	lib.initialised = false
end

return lib