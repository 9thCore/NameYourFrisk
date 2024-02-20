local lib = {}
lib.interactable = {}
lib.initialised = false

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

local function WhiteText(center, text, ...)
	local t = CreateText("", ...)
	t.color = {1, 1, 1}
	t.HideBubble()
	t.SetFont("uidialog")
	t.SetText("[instant][effect:none]" .. text)
	t.progressmode = "none"
	if center then
		t.x = t.x - t.GetTextWidth()/2
	end
	return t
end

local function GetRows(charset)
	return math.ceil(#charset / lib.columns)
end

local function CreateCharset(result, charset, yoff, spacing)
	local cols = lib.columns
	local rows = GetRows(charset)
	for i = 1, rows do
		for j = 1, cols do
			local idx = (i - 1) * cols + j
			result[idx] = WhiteText(true, "[effect:shake, 0.6]" .. charset:sub(idx, idx), {320 + (j - cols/2 - 0.5) * lib.columnSpacing, 304 + yoff - (i - 1) * spacing}, 640, lib.layer)
		end
	end
end

-- Must be called once, before Update(), to initialise the name menu
function lib.Start()
	State("NONE")

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
			lib.rowSpacings[i] = 224 / GetRows(lib.charsets[i]) / #lib.charsets
		end
	end

	lib.interactable.label = WhiteText(true, "[charspacing:2]Name the fallen human.", {320, 394}, 640, lib.layer)

	local yoff = 0
	lib.interactable.charsets = {}
	lib.interactable.charsets[1] = {}
	CreateCharset(lib.interactable.charsets[1], lib.charsets[1], 0, lib.rowSpacings[1])
	for i = 2, #lib.charsets do
		yoff = yoff - lib.rowSpacings[i-1] * GetRows(lib.charsets[i-1]) - 8
		lib.interactable.charsets[i] = {}
		CreateCharset(lib.interactable.charsets[i], lib.charsets[i], yoff, lib.rowSpacings[i])
	end

	lib.interactable.quit = WhiteText(true, "Quit", {146, 54}, 640, lib.layer)
	lib.interactable.backspace = WhiteText(true, "Backspace", {300, 54}, 640, lib.layer)
	lib.interactable.done = WhiteText(true, "Done", {466, 54}, 640, lib.layer)

	lib.initialised = true
end

-- Must be called every frame, after Start()
function lib.Update()
	if not lib.initialised then
		error("Initialise the library with Start() before calling Update()!", 2)
	end
end

-- Remove all objects used by the library
function lib.Destroy()
	for k, v in pairs(lib.interactable) do
		v.Remove()
	end
	lib.interactable = {}
	lib.initialised = false
end

return lib