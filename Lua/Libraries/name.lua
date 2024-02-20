local lib = {}
lib.interactable = {}
lib.initialised = false

lib.charset1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- Characters used in the first set
lib.charset2 = "abcdefghijklmnopqrstuvwxyz" -- Characters used in the second set (can be set to empty, to only have the first set)
lib.columns = 7 -- Number of columns per set
lib.rows = 4 -- Number of rows per set
lib.layer = "Top" -- The layer at which to place the name menu
lib.hideBattle = true -- Whether to automatically hide the battle behind a black, fullscreen sprite
lib.newMusic = "" -- What music to change to; if left empty, will not change the music

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