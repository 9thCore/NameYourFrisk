-- NAME YOUR FRISK
-- v1.1
-- 9thCore

-- A library that recreates the name input menu.

local lib = {}
lib.interactable = {}
lib.initialised = false
lib.currentRow = 1
lib.currentCol = 1
lib.currentSet = 1
lib.currentScene = 1
lib.fadeTimer = 0
lib.nameTimer = 0
lib.name = ""
lib.aliases = nil

-- Characters used by each set
-- Number of entries dictates the number of charsets
-- There must be at least one charset
lib.charsets = {
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ",
	"abcdefghijklmnopqrstuvwxyz"
}

-- Font used by most of the UI, excluding name and characters
-- Default: "uidialog"
lib.uifont = "uidialog"

-- Font used by the name and characters
-- Default: "uidialog"
lib.namefont = "uidialog"

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
-- If left empty, will not change the music
-- Default: ""
lib.newMusic = ""

-- Color of unselected letters and buttons (0-1)
-- Default: {1, 1, 1}
lib.unselectedColor = {1, 1, 1}

-- Color of selected letters and buttons (0-1)
-- Default: {1, 1, 0}
lib.selectedColor = {1, 1, 0}

-- Color applied to every other text object
-- Default: {1, 1, 1}
lib.genericColor = {1, 1, 1}

-- Prefix applied to every letter in the charset
-- Adding color here disables selected letter and button highlighting (CYF)
-- Default: "[instant][effect:shake, 0.6]"
lib.charsetPrefix = "[instant][effect:shake, 0.6]"

-- Prefix applied to the label ("Name the fallen human.", "Is this name correct?", special name comment)
-- Color can be added freely here
-- Default: "[instant][effect:none][charspacing:2]"
lib.labelPrefix = "[instant][effect:none][charspacing:2]"

-- Prefix applied to every other text object
-- Color can be added freely here
-- Default: "[instant][effect:none]"
lib.textPrefix = "[instant][effect:none]"

-- Maximum name length
-- Cannot exceed 9 (CYF limit)
-- Default: 6 (Usual UNDERTALE limit)
-- For 7-9, higher care must be put into the special names
-- For instance, PAPYRU has a special case but PAPYRUS does not
lib.maxNameLength = 6

-- Sound that plays after the name is confirmed
-- Default: mus_cymbal
lib.confirmSound = "mus_cymbal"

-- Number of frames it takes to finish after confirmation
-- Default: 330
lib.confirmTime = 330

-- Number of frames it takes to fade in after confirmation
-- Default: 300
lib.fadeTime = 300

-- Text used by the library
-- The inputted name cannot be edited here, nor can the special name comment (as those are editable below)
lib.dictionary = {
	name_the_human = "Name the fallen human.",
	name_confirm = "Is this name correct?",
	quit = "Quit",
	backspace = "Backspace",
	done = "Done",
	yes = "Yes",
	no = "No",
	go_back = "Go back"
}

-- Names with custom comments about them, and optionally that disallow their usage
-- Names are lowered to check, so all the characters must be lowercase
-- If aliases is set, every name in that list will be automatically added to the map with the same properties (see napsta entry)
lib.specialNames = {
	frisk = {
		comment = "WARNING: This name will\nmake your life hell.\nProceed anyway?",
		allowed = true
	},
	aaaaaaaaa = {
		comment = "Not very creative...?",
		allowed = true
	},
	asgore = {
		comment = "You cannot.",
		allowed = false
	},
	toriel = {
		comment = "I think you should\nthink of your own\nname, my child.",
		allowed = false
	},
	sans = {
		comment = "nope.",
		allowed = false
	},
	undyne = {
		comment = "Get your OWN name!",
		allowed = false
	},
	flowey = {
		comment = "I already CHOSE\nthat name.",
		allowed = false
	},
	chara = {
		comment = "The true name.",
		allowed = true
	},
	alphys = {
		comment = "D-don't do that.",
		allowed = false
	},
	alphy = {
		comment = "Uh... OK?",
		allowed = true
	},
	papyru = {
		comment = "I'LL ALLOW IT!!!!",
		allowed = true
	},
	napsta = {
		comment = "...........\n(They're powerless to\nstop you.)",
		allowed = true,
		aliases = {"blooky"}
	},
	murder = {
		comment = "That's a little on-\nthe nose, isn't it...?",
		allowed = true,
		aliases = {"mercy"}
	},
	asriel = {
		comment = "...",
		allowed = false
	},
	catty = {
		comment = "Bratty! Bratty!\nThat's MY name!",
		allowed = true
	},
	bratty = {
		comment = "Like, OK I guess.",
		allowed = true
	},
	mtt = {
		comment = "OOOOH!!! ARE YOU\nPROMOTING MY BRAND?",
		allowed = true,
		aliases = {"metta", "mett"}
	},
	gerson = {
		comment = "Wah ha ha! Why not?",
		allowed = true
	},
	shyren = {
		comment = "..?",
		allowed = true
	},
	aaron = {
		comment = "Is this name correct? ; )",
		allowed = true
	},
	temmie = {
		comment = "hOI!",
		allowed = true
	},
	woshua = {
		comment = "Clean name.",
		allowed = true
	},
	jerry = {
		comment = "Jerry.",
		allowed = true
	},
	bpants = {
		comment = "You are really scraping the\nbottom of the barrel.",
		allowed = true
	}
}

-- Functions that you can override to change library behaviour
-- If overriden in order to add additional behaviour instead of replacing it, the original contents must be copied over

-- Returns either nil (meaning no special comment) or a table similar to the entries in specialNames above
-- comment and allowed must be set for the table returned, otherwise errors might occur
function lib.GetSpecialBehaviour(name)
	name = name:lower()
	return lib.aliases[name] or lib.specialNames[name]
end

-- Called every time a character is input into the name
-- The length is not checked outside
function lib.OnCharacterInput(char)
	if #lib.name >= lib.maxNameLength then
		return
	end

	lib.SetName(lib.name .. char)

	if lib.name:lower() == "gaster" then
		State("DONE")
	end
end

-- Called every time the last character is removed
function lib.OnBackspaceInput()
	lib.SetName(lib.name:sub(1, -2))
end

-- Called when the player presses on Quit
-- Useful if the mod contains a menu before the name input, for instance
function lib.OnQuit()
	lib.Destroy()
	State("DONE")
end

-- Called when the player presses on Done
function lib.OnNameConfirm()
	if #lib.name == 0 then
		return
	end

	local behaviour = lib.GetSpecialBehaviour(lib.name)
	if behaviour then
		lib.interactable.label2.SetText(behaviour.comment)
		if not behaviour.allowed then
			lib.ChangeScene(3)
			lib.SelectButton(6)
			return
		end
	else
		lib.interactable.label2.SetText(lib.dictionary.name_confirm)
	end

	lib.ChangeScene(2)
	lib.SelectButton(5)
end

-- Called when the player confirms their name after pressing Done
function lib.NameDone()
	Audio.PlaySound(lib.confirmSound)
	Audio.Stop()
	lib.ChangeScene(4)
end

-- Called when the library finishes its actions
function lib.Finish()
	-- Dummy
end

local function WhiteText(center, font, prefix, text, ...)
	local t = CreateText("", ...)
	t.HideBubble()
	t.SetFont(font)
	t.color = lib.genericColor
	t.linePrefix = prefix or lib.textPrefix
	t.SetText(text)
	t.progressmode = "none"
	if center then
		t.x = t.x - t.GetTextWidth()/2
	end
	return t
end

local function ColorText(color, ...)
	local t = WhiteText(...)
	t.color = color
	return t
end

local function CreateCharset(result, charset, yoff, spacing)
	local cols = lib.columns
	local rows = lib.GetRows(charset)
	for i = 1, rows do
		for j = 1, cols do
			local idx = lib.GetIndex(i, j)
			result[idx] = ColorText(lib.unselectedColor, true, lib.namefont, lib.charsetPrefix, charset:sub(idx, idx), {320 + (j - cols/2 - 0.5) * lib.columnSpacing, 304 + yoff - (i - 1) * spacing}, 640, lib.layer)
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
	lib.aliases = {}

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
	else
		lib.interactable.battleCover = spr
	end

	if lib.newMusic ~= "" then
		Audio.LoadFile(lib.newMusic)
	end

	for k, v in pairs(lib.specialNames) do
		if v.aliases then
			for i = 1, #v.aliases do
				local t = {}
				t.comment = v.comment
				t.allowed = v.allowed
				lib.aliases[v.aliases[i]] = t
			end
		end
	end

	if lib.columnSpacing == -1 then
		lib.columnSpacing = 448 / lib.columns
	end

	for i = 1, #lib.charsets do
		if lib.rowSpacings[i] == -1 then
			lib.rowSpacings[i] = 224 / lib.GetRows(lib.charsets[i]) / #lib.charsets
		end
	end

	lib.interactable.label = WhiteText(true, lib.uifont, lib.labelPrefix, lib.dictionary.name_the_human, {320, 394}, 640, lib.layer)

	local yoff = 0
	lib.interactable.charsets = {}
	lib.interactable.charsets[1] = {}
	CreateCharset(lib.interactable.charsets[1], lib.charsets[1], 0, lib.rowSpacings[1])
	for i = 2, #lib.charsets do
		yoff = yoff - lib.rowSpacings[i-1] * lib.GetRows(lib.charsets[i-1]) - 8
		lib.interactable.charsets[i] = {}
		CreateCharset(lib.interactable.charsets[i], lib.charsets[i], yoff, lib.rowSpacings[i])
	end

	lib.interactable.quit = ColorText(lib.unselectedColor, true, lib.uifont, nil, lib.dictionary.quit, {146, 54}, 640, lib.layer)
	lib.interactable.backspace = ColorText(lib.unselectedColor, true, lib.uifont, nil, lib.dictionary.backspace, {300, 54}, 640, lib.layer)
	lib.interactable.done = ColorText(lib.unselectedColor, true, lib.uifont, nil, lib.dictionary.done, {466, 54}, 640, lib.layer)

	lib.interactable.sceneCover = CreateSprite("black", lib.layer)
	lib.interactable.sceneCover.alpha = 0

	lib.interactable.label2 = WhiteText(true, lib.uifont, lib.labelPrefix, lib.dictionary.name_confirm, {320, 394}, 640, lib.layer)
	lib.interactable.label2.alpha = 0

	lib.interactable.no = ColorText(lib.unselectedColor, true, lib.uifont, nil, lib.dictionary.no, {160, 54}, 640, lib.layer)
	lib.interactable.no.alpha = 0

	lib.interactable.yes = ColorText(lib.unselectedColor, true, lib.uifont, nil, lib.dictionary.yes, {480, 54}, 640, lib.layer)
	lib.interactable.yes.alpha = 0

	lib.interactable.goback = ColorText(lib.unselectedColor, true, lib.uifont, nil, lib.dictionary.go_back, {160, 54}, 640, lib.layer)
	lib.interactable.goback.alpha = 0

	lib.interactable.name = WhiteText(false, lib.namefont, nil, "", {278, 346}, 640, lib.layer)

	lib.interactable.fader = CreateSprite("px", "Top")
	lib.interactable.fader.alpha = 0
	lib.interactable.fader.Scale(640, 480)

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
	elseif idx == 4 then
		lib.interactable.yes.color = color
	elseif idx == 5 then
		lib.interactable.no.color = color
	elseif idx == 6 then
		lib.interactable.goback.color = color
	end
end

function lib.SelectButton(idx)
	if lib.currentRow > -1 then
		lib.ColorCharacter(lib.currentSet, lib.currentRow, lib.currentCol, lib.unselectedColor)
		lib.currentRow = -1
	end
	lib.ColorButton(lib.currentCol, lib.unselectedColor)
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

function lib.RepositionName()
	lib.interactable.name.MoveTo(278 - lib.nameTimer + math.random() * 2, 346 - lib.nameTimer/2 + math.random() * 2 - lib.nameTimer/120*lib.interactable.label2.GetTextHeight())
	lib.interactable.name.Scale(1 + lib.nameTimer/50, 1 + lib.nameTimer/50)
	lib.interactable.name.rotation = (math.random() * 2 - 1) * (1 + lib.nameTimer / 60)
end

function lib.IncreaseNameTimerAndReposition()
	lib.nameTimer = math.min(lib.nameTimer + 1, 120)
	lib.RepositionName()
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

	if lib.currentRow == -4 then -- Fading
		lib.IncreaseNameTimerAndReposition()
		lib.fadeTimer = lib.fadeTimer + 1
		lib.interactable.fader.alpha = lib.fadeTimer/lib.fadeTime
		if lib.fadeTimer > lib.confirmTime then
			lib.Finish()
			lib.Destroy()
			return
		end
	elseif lib.currentRow == -3 then -- Disallowed name
		lib.IncreaseNameTimerAndReposition()
		if Input.Confirm == 1 then
			lib.ChangeScene(1)
			lib.SelectButton(3)
		end
	elseif lib.currentRow == -2 then -- Name confirm
		lib.IncreaseNameTimerAndReposition()
		if Input.Left == 1 or Input.Right == 1 then
			lib.SelectButton(9 - lib.currentCol)
		elseif Input.Confirm == 1 then
			if lib.currentCol == 5 then
				lib.ChangeScene(1)
				lib.SelectButton(3)
			else
				lib.NameDone()
			end
		end
	elseif lib.currentRow == -1 then -- Name input, bottom buttons
		if Input.Confirm == 1 then
			if lib.currentCol == 1 then
				lib.OnQuit()
			elseif lib.currentCol == 2 then
				lib.OnBackspaceInput()
			elseif lib.currentCol == 3 then
				lib.OnNameConfirm()
			end
		elseif Input.Cancel == 1 then
			lib.OnBackspaceInput()
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
	else -- Name input
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

function lib.ChangeScene(scene)
	if scene == 1 then -- Name input
		lib.interactable.sceneCover.alpha = 0
		lib.interactable.label2.alpha = 0
		lib.interactable.yes.alpha = 0
		lib.interactable.no.alpha = 0
		lib.interactable.goback.alpha = 0
		lib.currentRow = -1
		lib.nameTimer = 0
		lib.RepositionName()
		lib.interactable.name.rotation = 0
	elseif scene == 2 then -- Name confirmation
		lib.interactable.sceneCover.alpha = 1
		lib.interactable.label2.alpha = 1
		lib.interactable.yes.alpha = 1
		lib.interactable.no.alpha = 1
		lib.currentRow = -2
	elseif scene == 3 then -- Disallowed name
		lib.interactable.sceneCover.alpha = 1
		lib.interactable.label2.alpha = 1
		lib.interactable.goback.alpha = 1
		lib.currentRow = -3
	elseif scene == 4 then -- Fading
		lib.currentRow = -4
	end
end

function lib.SetName(name)
	lib.name = name
	lib.interactable.name.SetText(name)
end

-- Remove all objects used by the library
function lib.Destroy()
	RecursiveDestruction(lib.interactable)
	lib.interactable = {}
	lib.initialised = false
end

return lib