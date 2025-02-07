local httpr = game:GetService("HttpService")
local runs = game:GetService("RunService")
local messages = game:GetService("MessagingService")
local datastores = game:GetService("DataStoreService")
local OLDbans = datastores:GetDataStore("bans")
local OLDtracking = datastores:GetDataStore("tracking")
local OLDsettings = datastores:GetDataStore("settings")
local OLDfavorites = datastores:GetDataStore("favorites")
local mod = datastores:GetDataStore("moderation")

local presetColors = require(game.ReplicatedStorage.modules.colors)
local badgeAppearance = require(game.ReplicatedStorage.modules.badgeAppearance)
local chatTools = require(game.ReplicatedStorage.modules.chatTools)

local messages = game:GetService("MessagingService")
local teleport = game:GetService("TeleportService")
local autoresp = require(game.ReplicatedStorage.modules.autoresponse)
local basedSett = table.clone(require(game.ReplicatedStorage.modules.settings))

local gkey = "extremely very cool stats thing"

local this
this = {
	ownsBadges = {},
	loos = false,
	tock = function()
		return (DateTime.now().UnixTimestampMillis - DateTime.fromLocalTime().UnixTimestampMillis)/1000
	end,
	fetched = {
		transactions = {},
		list = {},
		auditlog = {},
		clothing = {},
		gallery = {},
		funds = math.huge
	},
	messages = {
		ban = "You have been banned! ||| Time Left: %s ||| Reason: %s",
		kick = "You have been kicked! ||| Reason: %s"
	},
	db = {
		_loop = function(...)
			while true do
				local scs, data = pcall(...)
				if scs then return data end
				task.wait(0.5)
			end
		end,
		getAsync = function(dat: DataStore, key: any) return this.db._loop(dat.GetAsync, dat, key) end,
		setAsync = function(dat: DataStore, key: any, value: any) return this.db._loop(dat.SetAsync, dat, key, value) end,
		removeAsync = function(dat: DataStore, key: any) return this.db._loop(dat.RemoveAsync, dat, key) end
	},
	mod = {
		cache = {},

		template = {
			report = {
				suspended = false,
				lastReport = 0,
				reports = 0,
				totalReports = 0
			},
			track = {
				tosLast = false,
				alt = false,
				changelog = false,
			},
			ban = {
				expires = 0,
				created = 0,
				moderator = "",
				reason = ""
			},
			settings = basedSett,
			preferences = {
				displayBadge = false,
				nameColor = false,
				hideTags = {}
			},
			history = {},
			favorites = {},
			dataMigrated = false
		},
		getOfflineMod = function(uid: number)
			return this.mod.getMod({
				UserId = uid
			})
		end,
		getMod = function(plr: Player)
			local ds = this.mod.cache[plr.UserId] or this.db.getAsync(mod, plr.UserId) or this.mod.template

			if ds.settings == "none" then ds.settings = basedSett end

			if typeof(ds.preferences.nameColor) ~= "string" then ds.preferences.nameColor = false end
			if ds.report.totalReports == nil then ds.report.totalReports = 0 end
			if ds.preferences == nil then ds.preferences = {} end
			if ds.preferences.hideTags == nil then ds.preferences.hideTags = {} end
			if ds.preferences.blendNameColor ~= nil then ds.preferences.blendNameColor = nil end

			if not ds.dataMigrated then
				local track = this.db.getAsync(OLDtracking, plr.UserId)
				if track then
					ds.track.tosLast = track.hasReadA or false
					ds.track.alt = track.alt or false
					ds.track.changelog = track.changelog or false
					this.db.removeAsync(OLDtracking, plr.UserId)
				end

				local ban = this.db.getAsync(OLDbans, plr.UserId)
				if ban then
					ds.ban.expires = ban.expiresAt or 0
					ds.ban.created = ban.bannedAt or 0
					ds.ban.moderator = ban.mod or ""
					ds.ban.reason = ban.reason or ""
					this.db.removeAsync(OLDbans, plr.UserId)
				end

				local setts = this.db.getAsync(OLDsettings, plr.UserId)
				if setts then
					for A, B in pairs(setts) do
						if ds.settings[A] == nil then continue end
						ds.settings[A] = B
					end
					this.db.removeAsync(OLDsettings, plr.UserId)
				end

				local favorites = this.db.getAsync(OLDfavorites, plr.UserId)
				if favorites then
					for A, B in pairs(favorites) do
						ds.favorites[A] = B
					end
					this.db.removeAsync(OLDfavorites, plr.UserId)
				end

				ds.dataMigrated = true
				this.mod.saveMod(plr)
			end

			for A, B in pairs(ds.favorites) do
				ds.favorites[A] = nil
				ds.favorites[tostring(A)] = B
			end

			for A, B in pairs(require(game.ReplicatedStorage.modules.settings)) do
				if ds.settings[A] ~= nil then continue end

				if typeof(B) == "table" then ds.settings[A] = B[1]
				else ds.settings[A] = B end
			end

			this.mod.cache[plr.UserId] = ds
			return ds
		end,
		saveOfflineMod = function(uid: number)
			if not this.mod.cache[uid] then return end
			return this.db.setAsync(mod, uid, this.mod.cache[uid])
		end,
		saveMod = function(plr: Player)
			return this.mod.saveOfflineMod(plr.UserId)
		end,
		deleteMod = function(plr: Player)
			this.mod.cache[plr.UserId] = nil
			return this.db.removeAsync(mod, plr.UserId)
		end,


		globalTemplate = {
			report = {
				keptAudios = {}
			}
		},
		getGlobalMod = function()
			local ds = this.mod.cache.global or this.db.getAsync(mod, "global") or this.mod.globalTemplate
			this.mod.cache.global = ds
			return ds
		end,
		_fsaveGlobal = function()
			if not this.mod.cache.global then return end
			return this.db.setAsync(mod, "global", this.mod.cache.global)
		end,
		saveGlobal = function()
			local ID = tick()
			_G.lastUpdateGlobal = ID

			task.delay(1.5, function()
				if _G.lastUpdateGlobal ~= ID then return end

				this.mod._fsaveGlobal()
			end)
		end,
	},
	util = {
		makeFormat = function(sec)
			local function tof(bal) return math.floor(bal*10)/10 end
			local function str(nmb)
				local stro = tostring(nmb)

				if math.floor(nmb) == nmb then return stro..".0"
				else return stro end
			end

			if sec < 60 then return str(tof(sec)).." seconds"
			elseif sec < 60*60 then return str(tof(sec/60)).." minutes"
			elseif sec < 60*60*24 then return str(tof(sec/(60*60))).." hours" end

			return str(math.floor(sec/(60*60*24))).." days"
		end,
		matchPlayerWithSelector = function(plr, sel)
			return plr.Name:lower():match(sel:lower()) or plr.DisplayName:lower():match(sel:lower()) or tostring(plr.UserId) == sel
		end,
		runEvery = function(sec, fnc, ...)
			local args = {...}
			local old = 0
			this.util.stepped(function()
				if tick() >= old then
					old = tick() + sec

					fnc(unpack(args))
				end
			end)
		end,
		stepped = function(fnc, ...)
			local args = {...}

			local event
			event = runs.Stepped:Connect(function()
				if this.loos then return event:Disconnect() end
				fnc(unpack(args))
			end)
		end,
		getTime = function(tim: string)
			local raah = tim:gsub("%D+", "")
			local sec = tonumber(raah)

			if tim:match("h") then sec *= 3600
			elseif tim:match("m") then sec *= 60 end

			return sec
		end,
	},
	msg = {
		awaitFoundPlayer = {},
		foundPlayer = {}
	},
	chat = {
		processSpeaker = function(plr: Player)
			if not this.fetched.auditlog[1] then return end
			if not this.fetched.transactions[1] then return end

			local mod = this.mod.getMod(plr)

			local tags = {}
			local contributor = {
				[12] = {"Con. III", Color3.fromHex("8fb7e2")},
				[5] = {"Con. II", Color3.fromHex("e2ac8f")},
				[3] = {"Con. I", Color3.fromHex("a58fe2")},
			}
			local donator = {
				[5000] = {"Absurd Donor", Color3.fromHex("06afc2")},
				[20] = {"Donor", Color3.fromHex("068d9d")},
			}
			local granks = {
				["server moderators"] = {"Moderator", Color3.fromHex("d18be9")},
				["creator"] = {"Founder (Tophat)", Color3.fromHex("9d53f1")}
			}
			local uids =  {
				["29444141"] = {"mario118118", Color3.fromHex("00ffff")},
				["304346361"] = {"Developer", Color3.fromHex("e763aa")},
				["1275426298"] = {"Designer", Color3.fromHex("c44957")},
			}

			local audios = 0
			local donations = 0
			for _, x in pairs(this.fetched.auditlog) do
				if x.user.id == plr.UserId then audios += 1 end
			end
			for _, x in pairs(this.fetched.transactions) do
				if x.user.id == plr.UserId then donations += x.price end
			end

			local function clr(x)
				return x:ToHex()
			end

			for y, x in pairs(contributor) do
				if audios >= y then
					table.insert(tags, {
						text = x[1],
						color = clr(x[2])
					});
					break
				end
			end
			for y, x in pairs(donator) do
				if donations >= y then
					table.insert(tags, {
						text = x[1],
						color = clr(x[2])
					});
					break
				end
			end

			for bid, x in pairs(badgeAppearance) do
				if not this.ownsBadges[plr.UserId][bid] then continue end
				if x[1] == "free" or x[1] == "easy" then continue end

				table.insert(tags, {
					text = x[2],
					color = "badge",
					badge = true,
					hidden = mod.preferences.displayBadge ~= x[2]
				})
			end

			local r, rank = pcall(plr.GetRoleInGroup, plr, 14517832)
			if r then
				local grank = granks[rank]
				if grank then
					table.insert(tags, {
						text = grank[1],
						color = clr(grank[2])
					})
				end
			end

			local urank = uids[tostring(plr.UserId)]
			if urank then
				table.insert(tags, {
					text = urank[1],
					color = clr(urank[2])
				})
			end

			for i, X in pairs(tags) do
				if X.badge then continue end
				if table.find(mod.preferences.hideTags, X.text) then X.hidden = true end
				tags[i] = X
			end

			local chatColor = chatTools:GetChatColorFromTags(tags)
			local nameColor = chatTools:RenderNameColor(plr.Name, mod.preferences.nameColor, tags, chatColor)

			plr:SetAttribute("chNameColor", nameColor)
			plr:SetAttribute("chChatColor", chatColor)
			plr:SetAttribute("chTags", httpr:JSONEncode(tags))
		end,
		checkMuted = function(plr: Player)
			local isMod = table.find(this.mods, plr.UserId)
			local isMuted = this.chat.mute.global or (not not table.find(this.chat.mute.players, plr.UserId))
			if isMod then isMuted = false end

			return isMuted
		end,
		handleCommand = function(plr: Player, command: TextChatCommand, text: string)
			local function err(msg)
				game.ReplicatedStorage.events.chat.SMessage:FireClient(plr, { Text = msg, Color = Color3.new(1, 0, 0) })
			end
			local function msg(msg)
				game.ReplicatedStorage.events.chat.SMessage:FireClient(plr, { Text = msg, Color = Color3.new(0.8, 1, 1) })
			end
			local function announce(msg)
				game.ReplicatedStorage.events.chat.SMessage:FireAllClients({ Text = msg, Color = Color3.new(0.8, 0.8, 0.8), TextSize = 19 })
			end
			local function announceAll(msg)
				messages:PublishAsync("action", {"chat", { Text = msg, Color = Color3.new(0.8, 0.8, 0.8):ToHex(), TextSize = 19 }})
			end
			local function announceOther(msg)
				messages:PublishAsync("action", {"chat."..(workspace.data.server.beta.Value and "main" or "beta"), { Text = msg, Color = Color3.new(0.8, 0.8, 0.8):ToHex(), TextSize = 19 }})
			end
			local function findPlayer(selector: string, multiple: boolean?, global: boolean?, offline: boolean?): (Player|{Player}|string|boolean, string|boolean)
				selector = selector:lower()

				if multiple then
					if selector == "all" then return game.Players:GetChildren()
					elseif selector == "me" then return {plr}, "instance"
					elseif selector == "others" then
						local t = {}
						for _, x in pairs(game.Players:GetChildren()) do
							if x ~= plr then
								t[#t+1] = x
							end
						end
						return t, "instance"
					elseif selector == "random" then
						local plrs = game.Players:GetChildren()
						table.remove(plrs, table.find(plrs, plr))
						return {plrs[math.random(1, #plrs)]}, "instance"
					end
				else
					if selector == "me" then return plr, "instance"
					elseif selector == "random" then
						local plrs = game.Players:GetChildren()
						table.remove(plrs, table.find(plrs, plr))
						return plrs[math.random(1, #plrs)], "instance"
					end
				end

				for _, x in pairs(game.Players:GetChildren()) do
					if this.util.matchPlayerWithSelector(x, selector) then
						return (multiple and {x} or x), "instance"
					end
				end

				if not multiple then
					if global then
						local ID = httpr:GenerateGUID()
						this.msg.awaitFoundPlayer[ID] = true

						msg("Looking for global player...")
						messages:PublishAsync("action", {"findplayer", selector, ID})

						local unti = tick()+2
						repeat task.wait() until this.msg.foundPlayer[ID] or tick() >= unti

						local plar = this.msg.foundPlayer[ID]
						this.msg.awaitFoundPlayer[ID] = nil
						this.msg.foundPlayer[ID] = nil

						if plar then return plar, "global"
						else err("Didn't find player!") end
					end

					if offline then
						msg("Looking for offline player...")
						local scs, id = pcall(game.Players.GetUserIdFromNameAsync, game.Players, selector)
						if scs and id then return selector, "offline" end
					end
				end

				return false, false
			end

			local isMod = table.find(this.mods, plr.UserId)
			local args = {unpack(text:split(" "), 2)}

			if isMod then
				if command.Name == "Commands" then
					msg("Here's a list of all the admin commands!")
					msg("  Datatype Guide:")
					msg("    [Oplayer] = selects players that are offline")
					msg("    [Gplayer] = selects players that are in other servers")
					msg("    [GOplayer] = selects players that are in other servers/offline\n")
					for _, x: TextChatCommand in pairs(game.ServerStorage["chat commands"]:GetDescendants()) do
						if not x:IsA("TextChatCommand") or x:GetAttribute("hidden") then continue end

						local args, desc = x:GetAttribute("args"), x:GetAttribute("description")
						local str = x.PrimaryAlias
						if x.SecondaryAlias ~= "" then str ..= " | "..x.SecondaryAlias end
						if args and args ~= "" then str ..= " "..args end
						str ..= " : "..desc

						msg(str)
					end

					return
				elseif command.Name == "Resubscribe" then
					this.msg.resubscribe()
					return msg("Done!")
				elseif command.Name == "Poll" then
					local tim = this.util.getTime(args[1] or "")
					if not tim or tim < 1 then return err("Time must be atleast 1 second!") end

					local options = (args[2] or ""):split(",")
					if not options[1] then return err("You must specify atleast 1 option!") end

					local question = table.concat({unpack(args, 3)}, " ")
					if #question < 1 then return err("Question must be atleast 1 character long!") end

					local id = tostring(this.tock())

					local atomap = {}
					for _, x in pairs(options) do atomap[x] = {} end
					local polldata = {
						answers = atomap
					}

					this.polls[id] = polldata
					messages:PublishAsync("action", {"makepoll", id, options})
					messages:PublishAsync("message", {"Poll", question, options, id})

					task.delay(tim, function()
						local text = {}
						local total = 0
						for _, j in pairs(this.polls[id].answers) do total += #j end

						for x, y in pairs(this.polls[id].answers) do
							text[#text+1] = `{x} - {#y} vote{#y ~= 1 and "s" or ""} ({math.floor((#y/total)*100)}%)`
						end
						announceAll(`Stats for the last poll!\n{table.concat(text, "\n")}`)

						this.polls[id] = nil
						messages:PublishAsync("action", {"deletepoll", id, options})
					end)
					return msg(`Your poll was started! Results will be sent to chat in {this.util.makeFormat(tim)}`)
				elseif command.Name == "MuteChat" then
					if this.chat.mute.global then return err("Chat is already muted!") end

					this.chat.mute.global = true
					return announce("Chat has been muted.")
				elseif command.Name == "UnmuteChat" then
					if not this.chat.mute.global then return err("Chat is already unmuted!") end

					this.chat.mute.global = false
					return announce("Chat has been unmuted.")
				elseif command.Name == "Mute" then
					if not args[1] or args[1] == "" then return err("Missing player!") end

					local Player = findPlayer(args[1], false, false, false)
					if not Player then return err("Player not found!") end
					if Player == plr then return err("You cannot mute yourself!") end
					local player: Player = Player

					if table.find(this.chat.mute.players, player.UserId) then return err(`{player.Name} is already muted!`) end
					this.chat.mute.players[#this.chat.mute.players+1] = player.UserId

					return announce(`{player.Name} has been muted`)
				elseif command.Name == "Unmute" then
					if not args[1] or args[1] == "" then return err("Missing player!") end

					local Player = findPlayer(args[1], false, false, false)
					if not Player then return err("Player not found!") end
					if Player == plr then return err("You cannot unmute yourself!") end
					local player: Player = Player

					if not table.find(this.chat.mute.players, player.UserId) then return err(`{player.Name} is already unmuted!`) end
					table.remove(this.chat.mute.players, table.find(this.chat.mute.players, player.UserId))

					return announce(`{player.Name} has been unmuted`)
				elseif command.Name == "Ban" then
					if not args[1] or args[1] == "" then return err("Missing player!") end

					local tim = this.util.getTime(args[2] or "")
					if not tim or tim < 1 then return err("Time must be atleast 1 second!") end

					local reason = table.concat({unpack(args, 3)}, " ")
					if #reason < 1 then reason = reason or "N/A" end

					local Player, type = findPlayer(args[1], false, true, true)
					if not Player then return err("Player not found!") end
					if Player == plr then return err("You cannot ban yourself!") end

					local uid
					if type == "instance" then uid = Player.UserId
					else uid = game.Players:GetUserIdFromNameAsync(Player) end

					local mod
					if type == "instance" then mod = this.mod.getMod(Player)
					else mod = this.mod.getOfflineMod(uid) end

					local display
					if type == "instance" then display = Player.Name
					else display = Player end

					if mod.ban.expires > this.tock() then return err(`{display} is already banned!`) end

					mod.ban.expires = this.tock() + tim
					mod.ban.created = this.tock()
					mod.ban.moderator = plr.Name
					mod.ban.reason = reason

					local kreason = this.messages.ban:format(this.util.makeFormat(tim), reason)

					if type == "instance" then Player:Kick(kreason)
					else
						if type == "global" then messages:PublishAsync("action", {"kick", Player, kreason})
						else this.mod.saveOfflineMod(Player) end
					end

					return announce(`{display} has been unbanned`)
				elseif command.Name == "Unban" then
					if not args[1] or args[1] == "" then return err("Missing player!") end

					local Player, type = findPlayer(args[1], false, true, true)
					if not Player then return err("Player not found!") end

					local uid
					if type == "instance" then uid = Player.UserId
					else uid = game.Players:GetUserIdFromNameAsync(Player) end

					local mod
					if type == "instance" then mod = this.mod.getMod(Player)
					else mod = this.mod.getOfflineMod(uid) end

					local display
					if type == "instance" then display = Player.Name
					else display = Player end

					if mod.ban.expires < this.tock() then return err(`{display} is already unbanned!`) end

					mod.ban.expires = 0
					mod.ban.created = 0
					mod.ban.moderator = ""
					mod.ban.reason = ""

					return announce(`{display} has been unbanned`)
				elseif command.Name == "Kick" then
					if not args[1] or args[1] == "" then return err("Missing player!") end

					local reason = table.concat({unpack(args, 2)}, " ")
					if #reason < 1 then reason = reason or "N/A" end

					local Player, type = findPlayer(args[1], false, true, false)
					if not Player then return err("Player not found!") end
					if Player == plr then return err("You can't kick yourself!") end

					local display
					if type == "instance" then display = Player.Name
					else display = Player end

					if type == "instance" then Player:Kick(this.messages.kick:format(reason))
					else messages:PublishAsync("action", {"kick", Player, reason}) end

					return announce(`{display} has been kicked`)
				elseif command.Name == "Update" then
					local BAV = workspace.data.server.beta.Value

					announceOther(`{BAV and "beta" or "main"} has just been updated. Check it out by using /{BAV and "beta" or "main"}`)

					local specific = BAV and "beta" or "stable"
					if args[1] then specific = nil end
					messages:PublishAsync("action", {"update", specific})
					_G.forceUpdate()

					return msg("Updated!")
				end
			else
				if command.Name == "Commands" then
					msg("Here's a list of all the public commands!")
					for _, x: TextChatCommand in pairs(game.ServerStorage["chat commands"]:GetDescendants()) do
						if not x:IsA("TextChatCommand") or not x:GetAttribute("public") or x:GetAttribute("hidden") then continue end
						local args, desc = x:GetAttribute("args"), x:GetAttribute("description")
						local str = x.PrimaryAlias or ""
						if x.SecondaryAlias ~= "" then str ..= " | "..x.SecondaryAlias end
						if args and args ~= "" then str ..= " "..args end
						str ..= " : "..desc

						msg(str)
					end
					return
				end
			end

			if command.Name == "Beta" then
				if workspace.data.server.beta.Value then return err("You are already playing the beta version!") end

				msg("Teleporting you to the beta version...")
				game.ReplicatedStorage.events.Teleporting:FireClient(plr, "Going to Beta...")
				return teleport:TeleportAsync(12681724978, {plr})
			elseif command.Name == "Stable" then
				if not workspace.data.server.beta.Value then return err("You are already playing the stable version!") end

				msg("Teleporting you to the stable version...")
				game.ReplicatedStorage.events.Teleporting:FireClient(plr, "Going to Stable...")
				return teleport:TeleportAsync(9937132110, {plr})
			elseif command.Name == "Rejoin" then
				if workspace.data.server.vip.Value then return err("Cannot rejoin in a VIP server!") end
				if runs:IsStudio() then return err("Cannot rejoin in studio!") end

				game.ReplicatedStorage.events.Teleporting:FireClient(plr, "Rejoining...")
				teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
				return msg("Rejoining...")
			elseif command.Name == "april fooled" then
				if not plr:FindFirstChild("PlayerGui") then return end
				script.scary:Clone().Parent = plr.PlayerGui
				return msg("No!")
			elseif command.Name == "john pork" then
				if not plr:FindFirstChild("PlayerGui") then return end
				script.jogn:Clone().Parent = plr.PlayerGui
				return msg("Get porked")
			end

			return err("You are not allowed to run this command!")
		end,
		mute = {
			global = false,
			players = {}
		},
		filter = true
	},
	polls = {},
	mods = {304346361, 747939692, 1275426298, 2386048434, 2773126909, 424200087},
	whitelist = {},
	version = {
		current = nil
	}
}

_G[gkey] = this

return this
