-- A basic encounter script skeleton that demonstrates the utility of the name library.
nameLib = require("name")

encountertext = "Poseur strikes a pose!"
nextwaves = {"bullettest_chaserorb"}
wavetimer = 4.0
arenasize = {155, 130}

enemies = {
"poseur"
}

enemypositions = {
{0, 0}
}

state = 0

function EncounterStarting()
    -- Set music
    nameLib.newMusic = "menu"
    nameLib.Start()

    -- Finish gets called when the library's operations are done
    nameLib.Finish = OnFinish
end

function OnFinish()
    state = 1
    Player.name = nameLib.name
    State("ACTIONSELECT")
    Audio.LoadFile("mus_battle1")
end

function Update()
    if state == 0 then
        nameLib.Update()
    end
end

function EnemyDialogueEnding()
    nextwaves = {}
end

function DefenseEnding()
    encountertext = RandomEncounterText()
end

function HandleSpare()
    State("ENEMYDIALOGUE")
end

function HandleItem(ItemID)
    BattleDialog({"Selected item " .. ItemID .. "."})
end