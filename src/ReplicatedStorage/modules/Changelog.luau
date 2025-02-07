local unicode = require(game.ReplicatedStorage.modules.unicode)
local popup = require(game.ReplicatedStorage.modules.PopupModule)

local this = {}

this.map = {
	["Changelog_070323_p2"] = {
		"Added special 'happy birthday' badge",
		"Added new 'undertale addict' badge",
		"Added undertale song indicator to the top right corner",
		"Fixed 'Accept' button",
		"Removed Tutorials - replaced by changelog",
		"Changed Filters tab to fancy buttons",
		"Added new Report Song button (COMING SOON!)",
		"Switched to the new chat!",
		"... And more bugfixes!"
	},
	["Changelog_070323_p3"] = {
		"Fixed undertale addict badge"
	},
	["Changelog_170323_p1"] = {
		"Fixed the mass error bug",
		"Fixed double-play audio bug",
		"Made 3D audio sound a bit better",
		"New public beta version of the game!",
		"New command: /beta - TPs you to beta version"
	},
	["Changelog_180323_p1"] = {
		"Implemented updates from the Beta: (patch 1-3)",
		"  Updating actually works now!",
		"  Improved changelog",
		"  Owns icons on badges",
		"  Fixed /poll command (staff)",
		"  Reporting audios now works!"
	},
	["Changelog_180323_p2"] = {
		"Implemented updates from the Beta: (patch 4)",
		"  Browser & Leaderboard tab improved! (no longer lags your device)",
		"  Code for Donate and Badges improved",
		`  Now using the {unicode.robux}, {unicode.premium} and {unicode.verified} icons because they look cool!`,
		"  Removed Popular and History filters for now",
		"  Improved ??? badge!",
		"  Added LORE",
		"  ... More code bugfixes!"
	},
	["Changelog_240323_p1"] = {
		"Implemented updates from the Beta: (patch 5)",
		"  Made fullscreen audio waveform better",
		"  Fixed audio reporting",
		"  Switched to a better faster database",
		"  Added a loading screen",
		"  silly little cat in loading screen x3 :p",
		"  Readded History filter!",
		"  ... Many bugfixes!"
	},
	["Changelog_240323_p2"] = {
		"Added audio sharing!",
		"fixed the server extremely lagging"
	},
	["Changelog_250323_p1"] = {
		"Implemented updates from the Beta: (patch 7-10)",
		"  Added chat customization! (tags & name color)",
		"  Added a 'gradients' gamepass for chat customization!",
		"  Fixed share links!",
		"  Added badge rarity to the badges tab!",
		"  Created new 'suggester' badge!",
		"  Added auto blend options to name colors!",
		"  Added 'Old Chat Look' setting!",
		"  Improved difficulty ratings & tag colors!",
	},
	["Changelog_250323_p2"] = {
		"Fixed mass exploiter badge bug.",
		"Fixed data not reloading bug.",
		"Fixed infinite loading bug."
	},
	["Changelog_250323_p3"] = {
		"Added a Bass filter in Audio Filters!",
		"Fixed sliders in Audio Filters.",
		"Improved keybinds for PC!",
		"... Bugfixes!"
	},
	["Changelog_300323_p1"] = {
		"Removed audio reporting due to abuse."
	},
	["Changelog_010423_p1"] = {
		"New april fools EXCLUSIVE badge 'april fooled'!",
		"Added badge descriptions to game page.",
		"Improved server performance!",
		"... Bugfixes!! ✨"
	},
	["Changelog_010423_p2"] = {
		"Made april fooled badge easier to get!",
		"Rebranded to OM Music (OMM)!",
		"Fixed audio creator bug",
		"Fixed navbar pos bug",
	},
	["Changelog_010423_p3"] = {
		"Type <b>john pork</b> in chat for a cool surprise!"
	},
	["Changelog_020423_p1"] = {
		"Removed 'april fooled' badge!",
		"Rebranded back to OC Music (OCM)!"
	},



	["Changelog_BETA_p1"] = {
		"New command: /stable | /main - TPs you to stable/main version",
	},
	["Changelog_BETA_p2"] = {
		"Updating actually works now! (hopefully)",
		"... Many bugfixes!"
	},
	["Changelog_BETA_p3"] = {
		"Improved changelog",
		"Owns icons on badges",
		"Fixed /poll command (staff)",
		"Reporting audios now works!"
	},
	["Changelog_BETA_p4"] = {
		"Browser & Leaderboard tab improved! (no longer lags your device)",
		"Code for Donate and Badges improved",
		`  Now using the {unicode.robux}, {unicode.premium} and {unicode.verified} icons because they look cool!`,
		"Removed Popular and History filters for now",
		"Improved ??? badge!",
		"Added LORE",
		"... More code bugfixes!"
	},
	["Changelog_BETA_p5"] = {
		"Made fullscreen audio waveform better",
		"Fixed audio reporting",
		"Switched to a better faster database",
		"Added a loading screen",
		"silly little cat in loading screen x3 :p",
		"Readded History filter!",
		"... Many bugfixes!"
	},
	["Changelog_BETA_p6"] = {
		"Added audio sharing!",
		"fixed the server extremely lagging"
	},
	["Changelog_BETA_p7"] = {
		"Added a 'gradients' gamepass!",
		"Added chat customization! (tags, name color & more soon)",
		"Fixed share links!",
		"... Many bugfixes, again!"
	},
	["Changelog_BETA_p8"] = {
		"Added badge rarity to the badges tab!",
		"Moved ??? rarity from impossible → difficult",
		"... Fixed 2 bugs!"
	},
	["Changelog_BETA_p9"] = {
		"Created new 'suggester' badge!",
		"Added auto blend options to name colors!",
		"Switched up badge rarities!",
		"... Bugfixes wooo!!"
	},
	["Changelog_BETA_p10"] = {
		"Added 'Old Chat Look' setting!",
		"Improved difficulty ratings & tag colors!",
		"... Bugfixes, again, again!!"
	},
	["Changelog_BETA_p11"] = {
		"New april fools EXCLUSIVE badge 'april fooled'!",
		"Added badge descriptions to game page.",
		"Improved server performance!",
		"... Bugfixes!! ✨"
	},
	["Changelog_BETA_p12"] = {
		"Made april fooled badge easier to get!",
		"Fixed audio creator bug",
		"Fixed navbar pos bug",
	},
	["Changelog_BETA_p13"] = {
		"Type <b>john pork</b> in chat for a cool surprise!"
	},
	["Changelog_BETA_p14"] = {
		"Removed 'april fooled' badge!",
		"Rebranded back to OC Music (OCM)!"
	},
}
local betaHistories = 14

local mainHistory = {
	"Changelog_070323_p2",
	"Changelog_070323_p3",
	"Changelog_170323_p1",
	"Changelog_180323_p1",
	"Changelog_180323_p2",
	"Changelog_240323_p1",
	"Changelog_240323_p2",
	"Changelog_250323_p1",
	"Changelog_250323_p2",
	"Changelog_300323_p1",
	"Changelog_010423_p1",
	"Changelog_010423_p2",
	"Changelog_010423_p3",
	"Changelog_020423_p1"
}

local betaHistory = {}
for i = 1, betaHistories do
	betaHistory[#betaHistory+1] = "Changelog_BETA_p" .. tostring(i)
end

this.current = workspace.data.server.beta.Value and betaHistory or mainHistory
this.thing = function(thingy: string)
	local current = thingy:split("_")[2]
	local patch = tonumber(thingy:split("_")[3]:sub(2))

	local dt = ""
	if current == "BETA" then
		dt = `Beta Changelog (patch {patch})`
	else
		local date = current:sub(1, 2)
		local month = current:sub(3, 4)
		local year = current:sub(5, 6)

		date, month, year = tonumber(date), tonumber(month), tonumber("20"..year)

		local dateFormat = "th"
		if date == 1 then dateFormat = "st"
		elseif date == 2 then dateFormat = "nd"
		elseif date == 3 then dateFormat = "rd" end

		local months = ("January|Feburary|March|April|June|July|August|September|October|Novemember|December"):split("|")
		dt = `Update Changelog ({date}{dateFormat} {months[month]}, {year} - patch {patch})`
	end
	local db = {}
	for _, x in pairs(this.map[thingy] or {"Changelog not found! Sorry!"}) do
		db[#db+1] = "- "..x
	end

	local newest = this.current[#this.current] == thingy
	local oldest = this.current[1] == thingy

	local stuff = {}
	if not oldest then stuff[#stuff+1] = "Previous" end
	stuff[#stuff+1] = "Ok"
	if not newest then stuff[#stuff+1] = "Next" end

	local respa = popup(dt, table.concat(db, "\n"), stuff)

	local lol = table.find(this.current, thingy)
	if respa == "Previous" then lol -= 1
	elseif respa == "Next" then lol += 1
	else return end

	if this.current[lol] then return this.thing(this.current[lol]) end
end
this.check = function(damn: string)
	if damn ~= this.current[#this.current] then
		return this.thing(this.current[#this.current])
	end
end
this.copyChangelog = function(thng)
	thng = thng or this.current[#this.current]
	thng = this.map[thng]

	local bram = {}
	for _, x in pairs(thng) do
		bram[#bram+1] = "- "..x
	end

	local scr = Instance.new("Script")
	scr.Name = "temp"
	scr.Source = table.concat(bram, "\n")
	scr.Parent = game.ServerStorage
	scr.Enabled = false
	game.Selection:Set({scr})
	game.Debris:AddItem(scr, 10)
end

return this
