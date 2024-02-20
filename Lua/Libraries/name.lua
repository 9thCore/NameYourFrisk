local lib = {}
lib.interactable = {}
lib.initialised = false

lib.charset1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- Characters used in the first set (default: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
lib.charset2 = "abcdefghijklmnopqrstuvwxyz" -- Characters used in the second set; can be set to empty, to only have the first set (default: "abcdefghijklmnopqrstuvwxyz")
lib.columns = 7 -- Number of columns per set (default: 7)
lib.columnSpacing = -1 -- Spacing between columns; if -1, will auto-calculate to fit in the original bounds (default: 64)
lib.rowSpacing1 = -1 -- Spacing between the first charset's rows; if -1, will auto-calculate to fit in the original bounds (default: 28)
lib.rowSpacing2 = -1 -- Spacing between the second charset's rows; if -1, will auto-calculate to fit in the original bounds (default: 28)
lib.layer = "Top" -- The layer at which to place the name menu (default: "Top")
lib.hideBattle = true -- Whether to automatically hide the battle behind a black, fullscreen sprite (default: true)
lib.newMusic = "" -- What music to change to; if left empty, will not change the music (default: "")

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

	if not lib.hideBattle then
		spr.Remove()
	end

	if lib.newMusic ~= "" then
		Audio.LoadFile(lib.newMusic)
	end

	if lib.columnSpacing == -1 then
		lib.columnSpacing = 448 / lib.columns
	end

	if lib.rowSpacing1 == -1 then
		lib.rowSpacing1 = 112 / GetRows(lib.charset1)
	end

	if lib.rowSpacing2 == -1 then
		lib.rowSpacing2 = 112 / GetRows(lib.charset2)
	end

	lib.interactable.label = WhiteText(true, "[charspacing:2]Name the fallen human.", {320, 394}, 640, lib.layer)

	lib.interactable.charset1 = {}
	lib.interactable.charset2 = {}
	CreateCharset(lib.interactable.charset1, lib.charset1, 0, lib.rowSpacing1)
	CreateCharset(lib.interactable.charset2, lib.charset2, -lib.rowSpacing1 * GetRows(lib.charset1) - 8, lib.rowSpacing2)

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