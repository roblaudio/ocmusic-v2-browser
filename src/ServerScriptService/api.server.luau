workspace.data.server.beta.Value = game.PlaceId == 12681724978
workspace.data.server.vip.Value = game.PrivateServerId ~= ""

local tips = require(game.ReplicatedStorage.modules.tips)
local presetColors = require(game.ReplicatedStorage.modules.colors)
local gamepasses = require(game.ReplicatedStorage.modules.gamepasses)
local chatTools = require(game.ReplicatedStorage.modules.chatTools)
local social = require(game.ReplicatedStorage.modules.social)
local unicode = require(game.ReplicatedStorage.modules.unicode)
local trim = require(game.ReplicatedStorage.modules.trim)
local changelog = require(game.ReplicatedStorage.modules.Changelog)
local blockAudios = require(game.ReplicatedStorage.modules.blockAudios)

local RNs = game:GetService("RunService")
local INs = game:GetService("InsertService")
local HTTPs = game:GetService("HttpService")
local MSGs = game:GetService("MessagingService")
local TPs = game:GetService("TeleportService")
local BDGs = game:GetService("BadgeService")
local MKPs = game:GetService("MarketplaceService")

-- skythefloof moment
local API_DUMP_URL = "https://raw.githubusercontent.com/roblaudio/ocmusic-archive-dumb/refs/heads/main/processed/v2.json"

local dataCache = {}

_G.mgs = MSGs -- just for console thingies

local api = "https://www.obbycreatormusic.com/api/"
local apikey = "6I46TOdmSQYelU731JPPnN4WwSYOHjDF70Bmyw7s4KRtIXdEm"

local allowGallery = require(game.ServerStorage.gallery)
local banGallery = require(game.ServerStorage.galleryBanKeywords)
local statz = require(game.ServerStorage.stats)

local celebrityBadges = {
	[304346361] = 2128350906,
	[747939692] = 2128352757,
	[29444141] = 2128352761,
	[1275426298] = 2128496513
}
local badgeIds = {
	groovebattle = 2128349931,
	bugreporter = 2128359677,
	exploiter = 2128373124,
	questionmark = 2128370851,
	altf4 = 2128421049,
	welcome = 2129337165,
	obsessed = 2129337220,
	obsessedundertale = 2141796844,
	birthday = 2141673520,
	suggester = 2142926405
}

local allBadges = {}
for _, x in pairs(celebrityBadges) do allBadges[#allBadges+1] = x end
for _, x in pairs(badgeIds) do allBadges[#allBadges+1] = x end

local function awardBadge(plr: Player, badgeId: number)
	local badgeCache: {} = statz.ownsBadges[plr.UserId] or {}
	if not badgeCache[badgeId] then
		badgeCache[badgeId] = true
		game.ReplicatedStorage.events.tracking.GotBadge:FireClient(plr, badgeId)
		game.ReplicatedStorage.events.chat.GotBadge:FireAllClients(badgeId, plr.Name)
		BDGs:AwardBadge(plr.UserId, badgeId)
		return true
	end
	return false
end

local willTeleport = false

_G.giveBugReport = function(plar: string)
	local plr = game.Players:FindFirstChild(plar)
	if not plr then return end

	awardBadge(plr, badgeIds.bugreporter)
end
_G.givePlayerBadge = function(plar: string, badge: number)
	local plr = game.Players:FindFirstChild(plar)
	if not plr then return end

	awardBadge(plr, badge)
end

local function exploiter(plr, reason)
	warn(`EXPLOITER: {plr.Name} got: {reason}`)
	game.ReplicatedStorage.events.Message:FireClient(plr, "What", "why would you need to exploit in this game lol", {"idk"})
	if awardBadge(plr, badgeIds.exploiter) then
		task.spawn(function()
			local req = HTTPs:RequestAsync({
				Url = api .. "send-message",
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json",
					["x-auth"] = apikey
				},
				Body = HTTPs:JSONEncode({
					channel = "987792198256955422",
					data = {
						content = `[ <@853550207039832084> ]\n**{plr.Name} got exploiter badge!!**\nreason: {reason}`
					}
				})
			})
		end)
	end
end

game.ReplicatedStorage.events.tabs.about.GBattle.OnServerEvent:Connect(function(plr)
	awardBadge(plr, badgeIds.groovebattle)
end)

-- NEW REMOTES STUFF
local userCache = {}
local userFetching = {}
game.ReplicatedStorage.events.GetPlayer.OnServerInvoke = function(plr, id)
	if typeof(id) ~= "number" then return exploiter(plr, "getplayer - id wasn't number") end
	if userFetching[id] then
		repeat task.wait() until not userFetching[id]
	end
	if userCache[id] then return userCache[id] end

	local triesLeft = 1
	local function retry()
		if triesLeft <= 0 then userFetching[id] = false; return error("Failed to fetch user.") end
		triesLeft -= 1

		local scs, user = pcall(HTTPs.GetAsync, HTTPs, `https://users.roproxy.com/v1/users/{id}`)
		if not scs or not user then task.wait(1); return retry() end

		user = HTTPs:JSONDecode(user)
		user = {
			id = user.id,
			name = user.name,
			displayname = user.displayName,
			verified = user.hasVerifiedBadge,
			role = nil
		}

		userCache[id] = user
		userFetching[id] = false
		return user
	end

	userFetching[id] = true
	return retry()
end

game.ReplicatedStorage.events.tabs.donate.GetClothing.OnServerInvoke = function()
	return {
		clothing = statz.fetched.clothing,
		funds = statz.fetched.funds
	}
end

local perPage = 25
game.ReplicatedStorage.events.tabs.audio.Pagination.OnServerInvoke = function(plr, query, filter, sort, creator, page)
	if typeof(query) ~= "string" then return exploiter(plr, "tabs.audio.pagination - query wasn't string") end
	if typeof(filter) ~= "string" then return exploiter(plr, "tabs.audio.pagination - filter wasn't string") end
	if typeof(sort) ~= "boolean" then return exploiter(plr, "tabs.audio.pagination - sort wasn't boolean") end
	if typeof(page) ~= "number" then return exploiter(plr, "tabs.audio.pagination - page wasn't number") end

	if filter == "creator" then
		if typeof(creator) ~= "string" then return exploiter(plr, "tabs.audio.pagination - creator wasn't string") end
	end

	local reverse = not sort

	local mod = statz.mod.getMod(plr)
	local auds = {}

	for i, x in pairs(statz.fetched.list) do
		local AA = x.name:lower():gsub(" ", "")
		local BB = tostring(x.id):lower():gsub(" ", "")
		local CC = query:lower():gsub(" ", "")

		if not AA:find(CC, 1, true) and not BB:find(CC, 1, true) then continue end

		if filter == "creator" then
			if not x.log then continue end
			if x.log.user.name:lower() ~= creator:lower() then continue end
		elseif filter == "favorites" then
			if not mod.favorites[tostring(x.id)] then continue end
		elseif filter == "history" then
			if not table.find(mod.history, x.id) then continue end
		elseif filter ~= "everything" then continue end

		auds[#auds+1] = x
	end

	if filter == "history" then
		table.sort(auds, function(a, b)
			local A, B = table.find(mod.history, a.id), table.find(mod.history, b.id)
			return A > B
		end)
	end

	if reverse then
		for i = 1, math.floor(#auds/2) do
			local j = #auds - i + 1
			auds[i], auds[j] = auds[j], auds[i]
		end
	end

	page = math.max(page, 1)
	local toPage = page*perPage
	local fromPage = (page-1)*perPage
	local ret = {}
	for i, x in pairs(auds) do
		if i <= fromPage or i > toPage then continue end
		x.index = i
		ret[#ret+1] = x
	end

	return ret
end

local perPageLD = 50
game.ReplicatedStorage.events.tabs.leaderboard.Pagination.OnServerInvoke = function(plr, category, page)
	if category ~= "audios" and category ~= "donations" then return exploiter(plr, "tabs.leaderboard.pagination - category wasn't audios/donations") end
	if typeof(page) ~= "number" then return exploiter(plr, "tabs.leaderboard.pagination - page wasn't number") end

	local min = category == "audios" and 3 or 5
	local goThrough = category == "audios" and statz.fetched.auditlog or statz.fetched.transactions

	local tall = {}
	for _, x in pairs(goThrough) do
		local dng = tall[x.user.id] or {
			user = x.user,
			count = 0
		}
		dng.count += x.price or 1

		tall[x.user.id] = dng
	end

	local ldb = {}
	for i, x in pairs(tall) do if x.count >= min then ldb[#ldb+1] = x end end

	table.sort(ldb, function(a, b)
		return a.count > b.count
	end)

	page = math.max(page, 1)
	local toPage = page*perPageLD
	local fromPage = (page-1)*perPageLD
	local ret = {}
	for i, x in pairs(ldb) do
		if i <= fromPage or i > 1000 or i > toPage then continue end
		x.index = i
		ret[#ret+1] = x
	end

	return ret
end

local whitelist = {}
for x in pairs(require(game.ReplicatedStorage.modules.Badges)) do table.insert(whitelist, tostring(x)) end

local badgeCache = {}
local function cacheBadge(plr, badge)
	if typeof(badge) ~= "string" then return exploiter(plr, "tabs.badges.getinfo - badge wasn't a string") end
	if badgeCache[badge] then return badgeCache[badge] end

	if not table.find(whitelist, badge) then return {} end

	local doata = HTTPs:GetAsync("https://badges.roproxy.com/v1/badges/"..badge)

	local scs, data = pcall(HTTPs.JSONDecode, HTTPs, doata)
	if not scs then return {} end

	if badge == "2143193454" then
		data.statistics.awardedCount = 80085
	end

	badgeCache[badge] = data
	return data
end
game.ReplicatedStorage.events.tabs.badges.GetInfo.OnServerInvoke = cacheBadge
statz.util.runEvery(20, function()
	for _, x in pairs(whitelist) do
		badgeCache[x] = nil
		pcall(cacheBadge, nil, x)
		task.wait()
	end
end)

statz.util.runEvery(60*5, function()
	game.ReplicatedStorage.events.chat.Tip:FireAllClients(tips[math.random(1, #tips)])
end)

local reqs = {}
game.ReplicatedStorage.events.tabs.settings.SyncRank.OnServerInvoke = function(plr)
	if not reqs[plr] then return false, "You're ratelimited! Please wait a bit." end
	reqs[plr] = true
	task.delay(20, function()
		reqs[plr] = false
	end)

	local response = HTTPs:RequestAsync({
		Url = api.."sync-rank",
		Method = "POST",
		Headers = {
			["x-auth"] = apikey,
			["Content-Type"] = "application/json"
		},
		Body = HTTPs:JSONEncode({
			user = plr.UserId
		})
	})
	if not response.Success then
		reqs[plr] = false
		return false, "Failed to contact server!"
	end

	local scs, json = pcall(HTTPs.JSONDecode, HTTPs, response.Body)
	if not scs then
		reqs[plr] = false
		return false, "Invalid response from server!"
	end

	return json.status, json.message
end

game.ReplicatedStorage.events.settings.Rejoin.OnServerEvent:Connect(function(plr)
	if workspace.data.server.vip.Value or game:GetService("RunService"):IsStudio() then return end
	TPs:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
end)

game.ReplicatedStorage.events.tracking.GotBadge.OnServerEvent:Connect(function(plr)
	exploiter(plr, "player tried to intentionally get exploiter badge (tracking.GotBadge)")
end)
game.ReplicatedStorage.events.chat.SMessage.OnServerEvent:Connect(function(plr)
	exploiter(plr, "player tried to intentionally get exploiter badge (chat.SMessage)")
end)
game.ReplicatedStorage.events.tabs.donate.Receipt.OnServerEvent:Connect(function(plr)
	exploiter(plr, "player tried to intentionally get exploiter badge (tabs.donate.Receipt)")
end)
game.ReplicatedStorage.events.chat.GotBadge.OnServerEvent:Connect(function(plr)
	exploiter(plr, "player tried to intentionally get exploiter badge (chat.GotBadge)")
end)
game.ReplicatedStorage.events["Get Exploiter Badge"].OnServerEvent:Connect(function(plr, res)
	exploiter(plr, res and ("client side exploiter detection: "..tostring(res)) or "player tried to intentionally get exploiter badge (ReqEB)")
end)
game.ReplicatedStorage.events.tracking.LogError.OnServerEvent:Connect(function(plr, msg)
	if typeof(msg) ~= "string" then return exploiter("reporterror - error isn't string") end
	if msg:lower():find("failed to load sound") then return end
	if msg:lower():find("action item") then return end
	if msg:lower():find("string contains invalid utf") then return end
	if msg:lower():find("isteleporting") then return end

	if msg:lower():find("script '', line") then return exploiter("reporterror - mf got an error in their script") end

	game.TestService:Message("Client error:\n\n"..msg)
	game.ReplicatedStorage.events.tracking.LogError:FireClient(plr)
end)

local socialTemp = {
	tab = "About",
	song = {
		available = false,
		watching = {},
		playing = false,

		id = false,
		time = 0,
		speed = 1,
		looped = false
	}
}
local socials = {}

local function getEverythingSocial()
	local everything = {}
	for y, x in pairs(socials) do
		local plr: Player
		for _, plar in pairs(game.Players:GetChildren()) do
			if plar.UserId == y then plr = plar end
		end
		if not plr then continue end

		local song
		for _, zaza in pairs(statz.fetched.list) do
			if zaza.id == x.song.id then song = zaza.name end
		end

		everything[#everything+1] = {
			user = {
				id = plr.UserId,
				name = plr.Name,
				displayname = plr.DisplayName,
				verified = plr.HasVerifiedBadge
			},
			doing = {
				tab = x.tab,
				song = song,
				songPlaying = x.song.playing
			}
		}
	end

	return everything
end

local function softClone(t)
	if typeof(t) == "boolean" then return not not t
	elseif typeof(t) == "string" then return ""..t
	elseif typeof(t) == "number" then return t+0 end
end
local function deepClone(t)
	if typeof(t) ~= "table" then return softClone(t) end
	local j = {}

	local function iterate(x, b)
		for A, B in pairs(x) do
			if typeof(B) == "table" then
				b[A] = table.clone(B)
			else b[A] = softClone(B) end
		end
	end
	iterate(t, j)

	return j
end

local function sendSocialFollowers(player, s)
	local scl = socials[player]
	if not scl then return end

	if s then
		for X, Y in pairs(s) do
			if scl[X] == nil then scl.song[X] = Y
			else scl[X] = Y end
		end
	end

	for _, x in pairs(scl.song.watching) do
		local S = deepClone(scl)
		S.song.watching = {}
		S.song.time = statz.tock() - S.song.time
		game.ReplicatedStorage.events.social.Updated:FireClient(x, player, S)
	end

	game.ReplicatedStorage.events.social.Updated:FireAllClients("global", getEverythingSocial())
end

game.ReplicatedStorage.events.social.RequestList.OnServerInvoke = function(plr)
	return getEverythingSocial()
end

local settingsCache = {}
local trackCache = {}
local hasSecretBadge = {}
local reqdt = {}
local function processPlayer(plr: Player)
	if plr.AccountAge < 30 and not RNs:IsStudio() and not table.find(statz.whitelist, plr.UserId) then plr:Kick(statz.messages.kick:format("Your account must be atleast 30 days old!")) end

	socials[plr.UserId] = deepClone(socialTemp)

	local llstat = Instance.new("StringValue", plr)
	llstat.Name = "llstat"
	llstat.Value = "loading"
	local gamepassSts = Instance.new("Configuration", plr)
	gamepassSts.Name = "gamepasses"

	llstat.Value = "preparing"
	local launchData = plr:GetJoinData()
	launchData = launchData and launchData.LaunchData or ""

	if not workspace.data.server.beta.Value and launchData == "gotobeta" then
		return TPs:TeleportAsync(12681724978, {plr})
	end

	local lnch = Instance.new("StringValue", plr:WaitForChild("PlayerGui"))
	lnch.Name = "launchData"
	lnch.Value = launchData

	llstat.Value = "getting data"
	local mod = statz.mod.getMod(plr)

	if mod.ban.expires > statz.tock() then
		plr:Kick(statz.messages.ban:format(statz.util.makeFormat(mod.ban.expires - statz.tock()), mod.ban.reason))
		return
	end

	-- cache all badges
	llstat.Value = "getting badges"
	statz.ownsBadges[plr.UserId] = {}
	for _, x in pairs(allBadges) do
		if not statz.ownsBadges[plr.UserId] then return end
		statz.ownsBadges[plr.UserId][x] = false -- BDGs:UserHasBadgeAsync(plr.UserId, x)
	end

	-- cache all gamepasses
	llstat.Value = "getting gamepasses"
	for a, b in pairs(gamepasses.id) do
		gamepassSts:SetAttribute(b, MKPs:UserOwnsGamePassAsync(plr.UserId, a))
	end

	llstat.Value = "processing chat"
	statz.chat.processSpeaker(plr)

	llstat.Value = "checking user badges"
	for J, H in pairs(celebrityBadges) do
		local does = false
		for _, g in pairs(game.Players:GetChildren()) do if g.UserId == J then does = true end end

		if does then
			for _, g in pairs(game.Players:GetChildren()) do
				awardBadge(g, H)
			end
		end
	end

--	llstat.Value = "giving welcome badge"
--	awardBadge(plr, badgeIds.welcome)

	llstat.Value = "checking tracking stuff"
	local yo = workspace.data.game.lastTos.Value
	if mod.track.tosLast ~= yo then mod.track.tosLast = false end

	if mod.track.alt then awardBadge(plr, badgeIds.altf4) end

	llstat.Value = "loading in"
	task.wait(1)

	llstat:Destroy()
	plr:SetAttribute("loaded", true)
end

game.Players.PlayerAdded:Connect(processPlayer)
for _, g in pairs(game.Players:GetChildren()) do task.spawn(processPlayer, g) end

task.delay(25, function()
	statz.util.runEvery(10, function()
		local now = DateTime.now():ToUniversalTime()

		if now.Day == 7 and now.Month == 3 then
			for _, plr in pairs(game.Players:GetChildren()) do
				awardBadge(plr, badgeIds.birthday)
			end
		end
	end)
end)

game.ReplicatedStorage.events.tracking.RequestData.OnServerInvoke = function(plr)
	return statz.mod.getMod(plr)
end

local playingSongs = {}
local playingSongsJ = {}

game.ReplicatedStorage.events.social.PlaybUpdate.OnServerEvent:Connect(function(plr, act, ...)
	local socl = socials[plr.UserId]
	if not socl then return end
	local args = {...}

	if act == "time" then
		if typeof(args[1]) ~= "number" then return exploiter(plr, "social.playbupdate - time - args[1] wasn't number") end

		sendSocialFollowers(plr.UserId, {
			time = statz.tock() - args[1]
		})
	elseif act == "speed" then
		if typeof(args[1]) ~= "number" then return exploiter(plr, "social.playbupdate - speed - args[1] wasn't number") end

		sendSocialFollowers(plr.UserId, {
			speed = args[1]
		})
	elseif act == "loop" then
		if typeof(args[1]) ~= "boolean" then return exploiter(plr, "social.playbupdate - loop - args[1] wasn't boolean") end

		sendSocialFollowers(plr.UserId, {
			looped = args[1]
		})
	else return exploiter(plr, "social.playbupdate - act was invalid") end
end)

local tabMap = {
	about = "About",
	audios = "Browser",
	badges = "Badges",
	chattags = "Chat Tags",
	donate = "Donate",
	leaderboard = "Leaderboard",
	settings = "Settings"
}
game.ReplicatedStorage.events.social.TabUpdate.OnServerEvent:Connect(function(plr, tab)
	if typeof(tab) ~= "string" then return exploiter(plr, "social.tabupdate - tab wasn't string") end

	if not tabMap[tab] then return exploiter(plr, "social.tabupdate - invalid tab") end

	local socl = socials[plr.UserId]
	sendSocialFollowers(plr.UserId, {
		tab = tabMap[tab]
	})
end)

game.ReplicatedStorage.events.social.SongUpdate.OnServerEvent:Connect(function(plr, state, id, tim)
	if typeof(state) ~= "string" then return exploiter(plr, "social.songupdate - state wasn't string") end

	local ID = tick()
	if state == "played" then
		if typeof(id) ~= "string" then return exploiter(plr, "social.songupdate - played - id wasn't number") end
		if typeof(tim) ~= "number" then return exploiter(plr, "social.songupdate - played - tim wasn't number") end

		local socl = socials[plr.UserId]
		if socl then
			sendSocialFollowers(plr.UserId, {
				time = statz.tock()-tim,
				id = tonumber(id),
				playing = true
			})
		end

		if playingSongs[plr] == id then return end
		playingSongs[plr] = id
		playingSongsJ[plr] = ID

		game.ReplicatedStorage.events.tabs.audio.PlayedAt:FireClient(plr, true)
		task.delay(3600, function()
			if playingSongsJ[plr] ~= ID then return end
			awardBadge(plr, badgeIds.obsessed)
		end)

		local name
		for _, x in pairs(statz.fetched.list) do
			if tostring(x.id) == id then
				name = x.name
			end
		end
		if not name then return end

		local undertail = false
		for _, x in pairs(blockAudios.undertale) do
			if name:lower():find(x) then undertail = true end
		end

		if not undertail then return end
		task.delay(600, function()
			if playingSongsJ[plr] ~= ID then return end
			awardBadge(plr, badgeIds.obsessedundertale)
		end)
	elseif state == "paused" then
		local socl = socials[plr.UserId]
		if socl then
			sendSocialFollowers(plr.UserId, {
				playing = false
			})
		end

		game.ReplicatedStorage.events.tabs.audio.PlayedAt:FireClient(plr, false)
		playingSongsJ[plr] = ID
		playingSongs[plr] = nil
	elseif state == "stopped" then
		local socl = socials[plr.UserId]
		if socl then
			sendSocialFollowers(plr.UserId, {
				id = false,
				available = false
			})
		end
	else return exploiter(plr, "social.songupdate - invalid state") end
end)

local reportsCooldown = {}
local function noRC(plr: Player)
	reportsCooldown[plr] = nil
end
local function setRC(plr: Player)
	reportsCooldown[plr] = statz.tock()+600
	task.delay(600, noRC, plr)
end

local atemplatelog = {
	user = {
		id = 1,
		name = "Roblox",
		displayname = "Roblox",
		role = "Guest"
	},
	asset = {
		id = 123456789,
		name = "poggers",
		when = -1
	}
}
game.ReplicatedStorage.events.tabs.audio.GetInfo.OnServerInvoke = function(plr: Player, audio: number)
	if typeof(audio) ~= "number" then return false end
	repeat task.wait() until statz.fetched.auditlog[1] and statz.fetched.list[1]

	local snd
	for _, x in pairs(statz.fetched.list) do
		if tostring(x.id) == tostring(audio) then
			snd = x
		end
	end
	if not snd then return false end

	snd.log = atemplatelog
	for _, x in pairs(statz.fetched.auditlog) do
		if x.asset.id == snd.id then
			snd.log = x
		end
	end

	return true, snd
end

game.ReplicatedStorage.events.tracking.UpdateSettings.OnServerEvent:Connect(function(plr, action, ...)
	if typeof(action) ~= "string" then return exploiter(plr, "tracking.updatesettings - action wasn't string") end
	local args = {...}
	local mod = statz.mod.getMod(plr)

	if action == "tosLast" then
		mod.track.tosLast = workspace.data.game.lastTos.Value
	elseif action == "changelog" then
		mod.track.changelog = changelog.current[#changelog.current]
	elseif action == "favorite" then
		if typeof(args[1]) ~= "number" then return exploiter(plr, "tracking.updatesettings - favorite - args[1] wasn't number") end
		if typeof(args[2]) ~= "boolean" then return exploiter(plr, "tracking.updatesettings - favorite - args[1] wasn't boolean") end

		local ids = {}
		for _, d in pairs(statz.fetched.list) do ids[d.id] = true end
		if not ids[args[1]] then return end

		mod.favorites[tostring(args[1])] = args[2] or nil
	elseif action == "alt" then
		if typeof(args[1]) ~= "boolean" then return exploiter(plr, "tracking.updatesettings - alt - args[1] wasn't boolean") end
		mod.track.alt = args[1]
	elseif action == "history" then
		if typeof(args[1]) ~= "number" then return exploiter(plr, "tracking.updatesettings - history - args[1] wasn't number") end

		local add
		for _, x in pairs(statz.fetched.list) do
			if x.id == args[1] then add = x end
		end
		if not add then return end

		local index = table.find(mod.history, add.id)
		if index and index <= 25 then
			table.remove(mod.history, index)
		end
		mod.history[#mod.history+1] = add.id
		while #mod.history >= 150 do
			table.remove(mod.history, 1)
		end
	elseif action == "pref.namecolor" then
		if typeof(args[1]) ~= "string" then return exploiter(plr, "tracking.updatesettings - pref.namecolor - args[1] wasn't string") end

		local set = presetColors.gradients[args[1]]
		if set and not plr.gamepasses:GetAttribute("gradients") then return end

		set = set or presetColors.colors[args[1]]
		if not set then return exploiter(plr, "tracking.updatesettings - pref.namecolor - args[1] wasn't preset color") end

		local tags = HTTPs:JSONDecode(plr:GetAttribute("chTags"))

		mod.preferences.nameColor = args[1]
		plr:SetAttribute("chNameColor", chatTools:RenderNameColor(plr.Name, args[1], tags, plr:GetAttribute("chChatColor")))
	elseif action == "pref.toggletag" then
		if not plr:GetAttribute("chTags") then return exploiter(plr, "tracking.updatesettings - pref.toggletag - no chat tags yet") end
		if typeof(args[1]) ~= "string" then return exploiter(plr, "tracking.updatesettings - pref.toggletag - args[1] wasn't string") end
		if typeof(args[2]) ~= "boolean" then return exploiter(plr, "tracking.updatesettings - pref.toggletag - args[2] wasn't boolean") end

		local tags = HTTPs:JSONDecode(plr:GetAttribute("chTags"))

		local function shidden(a, b)
			local index = table.find(mod.preferences.hideTags, a)
			if b then
				if not index then mod.preferences.hideTags[#mod.preferences.hideTags+1] = a end
			elseif not b then
				if index then table.remove(mod.preferences.hideTags, index) end
			end
		end

		local choseBadge = false
		for _, A in pairs(tags) do
			if A.text == args[1] and A.badge then choseBadge = true end
		end
		for i, A in pairs(tags) do
			if choseBadge and A.badge then
				A.hidden = not (A.text == args[1] and not args[2])
				tags[i] = A
			elseif not choseBadge and not A.badge then
				if A.text == args[1] then
					A.hidden = args[2]
					shidden(args[1], args[2])
					tags[i] = A
				end
			end
		end

		if choseBadge then mod.preferences.displayBadge = (not args[2]) and args[1] or false end

		local newChatColor = chatTools:GetChatColorFromTags(tags)

		plr:SetAttribute("chNameColor", chatTools:RenderNameColor(plr.Name, mod.preferences.nameColor, tags, newChatColor))
		plr:SetAttribute("chChatColor", newChatColor)
		plr:SetAttribute("chTags", HTTPs:JSONEncode(tags))
	else return exploiter(plr, "tracking.updatesettings - invalid action") end
	game.ReplicatedStorage.events.tracking.UpdateSettings:FireClient(plr, mod)
end)

game.ReplicatedStorage.events.settings.Update.OnServerEvent:Connect(function(plr, key, val)
	if typeof(key) ~= "string" or (typeof(val) ~= "string" and typeof(val) ~= "boolean") then return exploiter(plr, "settings.update - key/value isn't a string") end

	local allow = false

	local settingss = require(game.ReplicatedStorage.modules.settings)
	local stn = settingss[key]
	if stn ~= nil then
		if typeof(stn) == "table" then
			if typeof(val) == "string" and table.find(stn, val) then allow = true end
		elseif typeof(stn) == "boolean" then
			if typeof(val) == "boolean" then allow = true end
		end
	end
	if not allow then return exploiter(plr, `settings.update - player tried to set "{key:sub(1,15)}" to "{tostring(val):sub(1,15)}"`) end

	local mod = statz.mod.getMod(plr)
	mod.settings[key] = val
end)

local qbadgeCooldown = {}
game.ReplicatedStorage.events.tracking.RunQBadge.OnServerEvent:Connect(function(plr)
	if plr:FindFirstChild("lld") then return end
	if statz.ownsBadges[plr.UserId][badgeIds.questionmark] then return end

	qbadgeCooldown[plr] = true
	task.delay(0.5, function()
		qbadgeCooldown[plr] = false
	end)
	if Random.new():NextInteger(0, 500) == 100 then
		game.ReplicatedStorage.events.tracking.RunQBadge:FireClient(plr)
		task.wait(10)

		awardBadge(plr, badgeIds.questionmark)
	end
end)

game.Players.PlayerRemoving:Connect(function(plr)
	for A, B in pairs(socials) do
		for i, x in pairs(B.song.watching) do
			if x == plr then table.remove(B.song.watching, i) end
		end
	end

	sendSocialFollowers(plr.UserId, false)
	socials[plr.UserId] = nil

	playingSongsJ[plr] = nil
	playingSongs[plr] = nil
	statz.ownsBadges[plr.UserId] = nil

	if not plr:GetAttribute("yikes") then statz.mod.saveMod(plr) end
	statz.mod.cache[plr.UserId] = nil
end)

game.ReplicatedStorage.events.settings.Reset.OnServerInvoke = function(plr)
	statz.mod.deleteMod(plr)
	plr:Kick("Data cleared! Please rejoin.")
end

MKPs.PromptPurchaseFinished:Connect(function(plr: Player, asset, purc)
	if purc then
		local info = MKPs:GetProductInfo(asset)
		game.ReplicatedStorage.events.tabs.donate.Receipt:FireClient(plr, info)
		game.ReplicatedStorage.events.chat.SMessage:FireAllClients({
			Text = `{plr.DisplayName} has bought {info.Name} for {unicode.robux}{info.PriceInRobux}`,
			Color = Color3.new(1, 0.87451, 0.411765),
			TextSize = 19
		})
	end
end)
MKPs.PromptGamePassPurchaseFinished:Connect(function(plr, asset, purc)
	if purc then
		local pass = gamepasses.id[asset]
		if not pass then return end

		plr.gamepasses:SetAttribute(pass, RNs:IsStudio() and true or MKPs:UserOwnsGamePassAsync(plr.UserId, asset))
	end
end)

game.ReplicatedStorage.events.Message.OnServerEvent:Connect(function(plr, id, resp)
	if typeof(id) ~= "string" or typeof(resp) ~= "string" then return exploiter(plr, "message - id/response is not a string") end
	local poll = statz.polls[id]
	if not poll then return end
	if not poll.answers[resp] then return exploiter("message - player sent invalid option") end

	if poll.isTemporary then
		MSGs:PublishAsync("action", {"pollvote", id, plr.UserId, resp})
	else
		if table.find(poll.answers[resp], plr.UserId) then return exploiter("message - player already answered poll") end
		table.insert(poll.answers[resp], plr.UserId)
	end
end)

local rqsnt = {}
local cids = {}
local Tids = {}

local doingRequest = false
local coolassets = {}
local status = "req;0;0"
local ocmCache, ocmClothing
local function doRequest()
	local function HttpGet(a)
		local scs, pr = pcall(HTTPs.GetAsync, HTTPs, a)
		if not scs then return error(pr.." "..a) end

		return pr
	end
	local function getOCMData()
        --local scs, dt = pcall(HTTPs.GetAsync, HTTPs, "https://ocmusic.github.io/api-archive/data-archive-v2.txt"--[[api.."get-data?nocache="..HTTPs:GenerateGUID(false)]], true)
        local scs, dt = pcall(HTTPs.GetAsync, HTTPs, API_DUMP_URL, true)
		if not scs then
			if ocmCache then return ocmCache
			else return error("Failed to get OCM data") end
		end

		ocmCache = dt
		return dt
	end
	local function getOCMClothing()
		local scs, dt = pcall(HTTPs.GetAsync, HTTPs, "https://catalog.roproxy.com/v1/search/items/details?Category=3&CreatorType=2&CreatorTargetId=32024987&limit=30", true) --14517832
		if not scs then
			if ocmClothing then return ocmClothing
			else return error("Failed to get OCM clothing") end
		end

		ocmClothing = dt
		return dt
	end

	coroutine.wrap(function()
		if doingRequest then return end
		doingRequest = true
		local A, B = pcall(function()
			status = "req;1;3"
			local alldata = HTTPs:JSONDecode(getOCMData())
			local ids = {}

			statz.fetched.auditlog = {}
			local temp = {}
			local alogg = {}
			for _, log in pairs(alldata.auditlog) do
				userCache[log.user.id] = log.user
				alogg[log.asset.id] = log

				temp[#temp+1] = log
			end
			statz.fetched.auditlog = temp

			statz.fetched.list = {}
			temp = {}
			for i, d in pairs(alldata.audios) do
				d.log = alogg[d.id]
				temp[#temp+1] = d
			end
			statz.fetched.list = temp

			statz.fetched.funds = alldata.funds
			statz.fetched.transactions = {}
			temp = {}
			for _, d in pairs(alldata.transactions) do
				if d.price < 1 then continue end
				d.user = userCache[d.user.id] or d.user
				temp[#temp+1] = d
			end
			statz.fetched.transactions = temp

			for _, plr in pairs(game.Players:GetChildren()) do
				task.spawn(statz.chat.processSpeaker, plr)
			end

			status = "req;2;3"
			statz.fetched.clothing = HTTPs:JSONDecode(getOCMClothing()).data
			status = "req;3;3"
		end)

		if not A then
			status = `error;{statz.tock()+10}`
			warn("Error at request:")
			print(B)
			task.wait(10)
			doingRequest = false
			doRequest()
		elseif game:GetService("RunService"):IsStudio() then
			status = `time;{statz.tock()+15}`
			workspace.data.server.ready.Value = true
			doingRequest = false
			task.wait(15)
			doRequest()
		else
			status = `time;{statz.tock()}`
			workspace.data.server.ready.Value = true
			doingRequest = false
		end
	end)()
end

local evvs = {}
local updateThingy = 0
local function resubscribe()
	for _, e in pairs(evvs) do e:Disconnect() end

	table.insert(evvs, MSGs:SubscribeAsync("message", function(doit)
		local dt = doit.Data
		if typeof(dt) == "string" then dt = HTTPs:JSONDecode(dt) end

		game.ReplicatedStorage.events.Message:FireAllClients(unpack(dt))
	end))
	table.insert(evvs, MSGs:SubscribeAsync("action", function(doit)
		local dt = doit.Data
		if typeof(dt) == "string" then dt = HTTPs:JSONDecode(dt) end

		local key = dt[1]
		if key == "update" then
			local x = workspace.data.server.beta.Value and "beta" or "stable"
			if dt[2] and dt[2] ~= x then return end

			_G.forceUpdate()
		elseif table.find({"kick", "message"}, key) then
			local plr
			for _, x in pairs(game.Players:GetChildren()) do
				if x.Name:lower() == dt[2]:lower() or tostring(x.UserId) == tostring(dt[2]) then plr = x end
			end
			if not plr then return end

			if key == "kick" then
				plr:Kick(dt[3])
			elseif key == "message" then
				game.ReplicatedStorage.events.Message:FireClient(plr, dt[3], dt[4], dt[5], dt[6])
			end
		elseif key == "findplayer" then
			local sel = dt[2]
			for _, p in pairs(game.Players:GetChildren()) do
				if statz.util.matchPlayerWithSelector(p, sel) then
					MSGs:PublishAsync("action", {"foundplayer", p.Name, dt[3]})
					return
				end
			end
		elseif key == "foundplayer" then
			if statz.msg.awaitFoundPlayer[dt[3]] then
				statz.msg.foundPlayer[dt[3]] = dt[2]
			end
		elseif key == "chat" then
			local dt = dt[2]
			if dt.Color then dt.Color = Color3.fromHex(dt.Color) end

			game.ReplicatedStorage.events.chat.SMessage:FireAllClients(dt)
		elseif key == "chat.beta" or key == "chat.main" then
			if key == "chat.beta" and not workspace.data.server.beta.Value then return end
			if key == "chat.main" and workspace.data.server.beta.Value then return end

			local dt = dt[2]
			if dt.Color then dt.Color = Color3.fromHex(dt.Color) end

			game.ReplicatedStorage.events.chat.SMessage:FireAllClients(dt)
		elseif key == "makepoll" then
			local id = dt[2]
			local opts = dt[3]

			if not statz.polls[id] then
				local atomap = {}
				for _, x in pairs(opts) do atomap[x] = true end
				local polldata = {
					answers = atomap,
					isTemporary = true
				}
				statz.polls[id] = polldata
			end
		elseif key == "deletepoll" then
			local id = dt[2]
			statz.polls[id] = nil
		elseif key == "pollvote" then
			local id = dt[2]
			local uid = dt[3]
			local resp = dt[4]

			local poll = statz.polls[id]
			if not poll or poll.isTemporary then return end

			if not poll.answers[resp] then return end
			if table.find(poll.answers[resp], uid) then return end

			table.insert(poll.answers[resp], uid)
		end
	end))
	table.insert(evvs, MSGs:SubscribeAsync("webaction", function(doit)
		local dt = doit.Data
		if typeof(dt) == "string" then dt = HTTPs:JSONDecode(dt) end

		local key = dt[1]

		if key == "reload" then
			if dt[2] == "progress" then status = `fetching;{dt[3]};{dt[4]}`
			elseif dt[2] == "finish" then
				doRequest()
			end
		elseif key == "updatemod" then
			local mod
			if dt[2] == "global" then mod = statz.mod.getGlobalMod()
			else
				local plr
				for _, x in pairs(game.Players:GetChildren()) do
					if x.Name:lower() == dt[2] or tostring(x.UserId) == tostring(dt[2]) then plr = x end
				end
				if not plr then return end

				mod = statz.mod.getMod(plr)
			end

			for A, B in pairs(dt[3]) do
				local path = A:split(".")
				local pat = mod
				local set = path[#path]

				for i, x in pairs(path) do
					if i ~= #path then pat = pat[x] end
				end

				local state, data = B[1], B[2]

				if state == "set" then pat[set] = data
				elseif state == "delete" then pat[set] = nil
				else
					pat = pat[set]
					if state == "push" then pat[#pat+1] = data
					elseif state == "insert" then pat[data] = B[3] end
				end
			end
		elseif key == "ignoremod" then
			local plr
			for _, x in pairs(game.Players:GetChildren()) do
				if x.Name:lower() == dt[2] or tostring(x.UserId) == tostring(dt[2]) then plr = x end
			end
			if not plr then return end

			plr:SetAttribute("yikes", true)
		end
	end))
end
resubscribe()
statz.msg.resubscribe = resubscribe

statz.util.runEvery(100, function()
	pcall(resubscribe)
end)

statz.version.current = INs:GetLatestAssetVersionAsync(game.PlaceId)

_G.forceUpdate = function()
	if game:GetService("RunService"):IsStudio() then statz.loos = true return end
	local Tps = game:GetService("TeleportService")

	game.ReplicatedStorage.events.Teleporting:FireAllClients("Updating...")
	statz.loos = true
	pcall(TPs.TeleportAsync, TPs, 12813434074, game.Players:GetChildren())
	for i = 1, 3 do
		for _, p in pairs(game.Players:GetChildren()) do pcall(TPs.TeleportAsync, TPs, 12813434074, {p}) end
		task.wait(2)
	end
	task.wait(1)
	for _, p in pairs(game.Players:GetChildren()) do p:Kick("Failed to teleport you :( Please rejoin.") end
end
game:BindToClose(_G.forceUpdate)

_G.fakeMario = function()
	game.ReplicatedStorage.events.chat.SMessage:FireAllClients({
		Text = "Your friend mario118118 has joined the experience.",
		Color = Color3.new(0.85, 0.85, 0.85)
	})
	task.wait(1.5)
	for _, x in pairs(game.Players:GetChildren()) do
		game.ReplicatedStorage.events.tracking.GotBadge:FireClient(x, 2128352761)
		game.ReplicatedStorage.events.chat.GotBadge:FireAllClients(2128352761, x.Name)
	end
end

local scountdown = 1666294200+(60*60*24*20)
local hasDidSCountdownThingy = false
statz.util.stepped(function()
	local rq = status:split(";")
	if rq[1] == "req" then
		workspace.data.server.rstatus.Value = `Request: {rq[2]}/{rq[3]}`
	elseif rq[1] == "time" then
		local nw = math.floor((statz.tock()-tonumber(rq[2]))*10)/10

		workspace.data.server.rstatus.Value = `Last Reload: {statz.util.makeFormat(nw)} ago`
	elseif rq[1] == "error" then
		local nw = math.floor((tonumber(rq[2])-statz.tock())*10)/10

		workspace.data.server.rstatus.Value = `Got Error! Retrying in {statz.util.makeFormat(nw)}`
	elseif rq[1] == "fetching" then
		workspace.data.server.rstatus.Value = `Fetching Data: {rq[2]}/{rq[3]}`
	end
end)
statz.util.stepped(function()
	for _, plr: TextSource in pairs(game.TextChatService.TextChannels.RBXGeneral:GetChildren()) do
		local isMod = table.find(statz.mods, plr.UserId)
		local isMuted = statz.chat.mute.global or (not not table.find(statz.chat.mute.players, plr.UserId))
		if isMod then isMuted = false end

		plr.CanSend = not isMuted
	end
end)

doRequest()
