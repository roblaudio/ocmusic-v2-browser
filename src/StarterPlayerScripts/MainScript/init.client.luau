repeat task.wait() until game:IsLoaded()

local figlets = require(game.ReplicatedStorage.modules.figlets):split("\n\n")
local badgeAppearance = require(game.ReplicatedStorage.modules.badgeAppearance)
local gamepasses = require(game.ReplicatedStorage.modules.gamepasses)
local precolors = require(game.ReplicatedStorage.modules.colors)
local chatTools = require(game.ReplicatedStorage.modules.chatTools)
local social = require(game.ReplicatedStorage.modules.social)
local unicode = require(game.ReplicatedStorage.modules.unicode)
local canint = require(game.ReplicatedStorage.modules.CanInteract)
local trim = require(game.ReplicatedStorage.modules.trim)
local popup = require(game.ReplicatedStorage.modules.PopupModule)
local notifs = require(game.ReplicatedStorage.modules.Notifications)
local changelog = require(game.ReplicatedStorage.modules.Changelog)
local dataGetter = require(game.ReplicatedStorage.modules.DataGetter)
--local tutorials = require(game.ReplicatedStorage.modules.Tutorials)
local CNTP = game:GetService("ContentProvider")
local HTTPs = game:GetService("HttpService")
local UIs = game:GetService("UserInputService")
local TPs = game:GetService("TeleportService")
local TWNs = game:GetService("TweenService")
local RNs = game:GetService("RunService")
local TXTs = game:GetService("TextService")
local BDGs = game:GetService("BadgeService")
local VCs = game:GetService("VoiceChatService")
local MKPs = game:GetService("MarketplaceService")
local PLCs = game:GetService("PolicyService")
local plr = game.Players.LocalPlayer
local pgui = plr:WaitForChild("PlayerGui")
local mouse = plr:GetMouse()

local topbars = {}
local mouseGui = game.StarterGui.mouse:Clone()
local gui = game.StarterGui.main:Clone()
gui.Enabled = true

_G.focused = true
UIs.WindowFocused:Connect(function()
	_G.focused = true
end)
UIs.WindowFocusReleased:Connect(function()
	_G.focused = false
end)

local doubleclickRT = 0
local slideprevRT = 0

--local chat = pgui:WaitForChild("Chat")
local damouse = mouseGui.mouse

gui.Parent = pgui
mouseGui.Parent = pgui

gui.DisplayOrder = 0
mouseGui.DisplayOrder = 2

TPs:SetTeleportGui(gui)

local inputBeganThingy = 0.075

local cam = Instance.new("Camera")

local sn = 0
local rt = 0
local desc

local function hoverDesc(x, text)
	x.MouseEnter:Connect(function()
		if not canint.check() then return end
		local txt = text
		if typeof(text) == "function" then txt = text() end
		if not txt then return end

		desc = {x, txt}
	end)
	x.MouseLeave:Connect(function()
		if not canint.check() then return end
		if desc and desc[1] == x then desc = nil end
	end)
end

local allicons = {
	check = "rbxassetid://11598893833",
	close = "rbxassetid://11598902972",
	error = "rbxassetid://11598902972",
	favorite = "rbxassetid://11598897627",
	filters = "rbxassetid://11598897285",
	headphones = "rbxassetid://11598897285",
	loop = "rbxassetid://11598896650",
	maximize = "rbxassetid://11598896325",
	minimize = "rbxassetid://11598896061",
	pause = "rbxassetid://11598895864",
	play = "rbxassetid://11598895598",
	tempo = "rbxassetid://11598895271"
}

local icons = {
	["pause"] = allicons.pause,
	["play"] = allicons.play,
	["error"] = allicons.error,
	["loading"] = "rbxasset://textures/DarkThemeLoadingCircle.png"
}
local descriptions = {
	pause = "Pause",
	play = "Play",
	error = "Audio couldn't load.",
	loading = "Loading..."
}

local hevents = {}

local isTouching = false

UIs.TouchStarted:Connect(function()
	isTouching = true
end)
UIs.TouchEnded:Connect(function()
	isTouching = false
end)

local function isInput(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function isReleased()
	return not UIs:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not isTouching
end
local function waitUntilRelease()
	repeat task.wait() until isReleased()
end

local function toClipboard(txt)
	canint.protect("clipboard")
	gui.clipboard.clp.Text = txt
	gui.clipboard.Visible = true

	local disb = false
	local evs = {}
	task.spawn(function()
		evs.focuslost = gui.clipboard.clp.FocusLost:Connect(function()
			disb = true
		end)

		evs.input = UIs.InputEnded:Connect(function(k)
			if UIs:GetFocusedTextBox() == gui.clipboard.clp then
				if (UIs:IsKeyDown(Enum.KeyCode.LeftControl) or UIs:IsKeyDown(Enum.KeyCode.RightControl)) and k.KeyCode == Enum.KeyCode.C then
					disb = true
				end
			end
		end)

		evs.cool = RNs.RenderStepped:Connect(function()
			gui.clipboard.clp:CaptureFocus()
			gui.clipboard.clp.SelectionStart = 1
			gui.clipboard.clp.CursorPosition = #txt+1
		end)
	end)

	repeat task.wait() until disb
	for _, G in pairs(evs) do G:Disconnect() end

	gui.clipboard.clp:ReleaseFocus()
	gui.clipboard.clp.CursorPosition = -1
	gui.clipboard.clp.SelectionStart = -1
	gui.clipboard.Visible = false
	gui.clipboard.clp.Text = ""
	canint.unprotect("clipboard")
end

local isfilt = false
local function makeImageStuff(snd, img, hovr, cid, fart)
	local dbsc
	local yeshover = false
	local isLoading = true
	if hevents[cid] then for _, H in pairs(hevents[cid]) do H:Disconnect() end end

	local function ply()
		task.spawn(function()
			task.wait()
			local bgz = snd.IsLoaded and (snd.IsPlaying and "pause" or "play") or (isLoading and "loading" or "error")
			local doita = icons[bgz]

			if not img:FindFirstChild("icon") then return end
			img.icon.Image = doita
			dbsc = descriptions[bgz]
			if desc and desc[1] == hovr then desc = {hovr, dbsc} end
			if bgz == "loading" then
				pcall(function()
					img.icon.Rotation = math.random(0, 90)
					while img.icon.Image == icons.loading do
						img.icon.Rotation += 8
						RNs.PreRender:Wait()
					end
					img.icon.Rotation = 0
				end)
			end
		end)
	end

	hoverDesc(hovr, function()
		if fart and isfilt then return end
		return dbsc
	end)

	hevents[cid] = {}
	table.insert(hevents[cid], snd.Ended:Connect(ply))
	table.insert(hevents[cid], snd.Loaded:Connect(ply))
	table.insert(hevents[cid], snd.Paused:Connect(ply))
	table.insert(hevents[cid], snd.Played:Connect(ply))
	table.insert(hevents[cid], snd.Resumed:Connect(ply))
	table.insert(hevents[cid], snd.Stopped:Connect(ply))
	ply()

	return function()
		isLoading = false
		ply()
	end
end

local function makeTimer(secs)
	secs = math.floor(secs)
	local scs = secs%60
	local mins = math.floor(secs/60)%60
	local hrs = math.floor(mins/60)

	if scs < 10 then scs = "0"..tostring(scs) end
	if hrs > 0 and mins < 10 then mins = "0"..tostring(mins) end
	if hrs > 0 then hrs = tostring(hrs)..":" else hrs = "" end

	return `{hrs}{mins}:{scs}`
end

local audplay, audtracker = nil, function(AD, elm) end
local evvs = {}

hoverDesc(gui.bgplayer.all.controls.share, "Share")
hoverDesc(gui.bgplayer.all.controls.filters, "Filters")
hoverDesc(gui.bgplayer.all.controls.close, "Close")
hoverDesc(gui.bgplayer.all.controls.jam, "Maximize")
hoverDesc(gui.bgplayer.all.scrollbar.controls.loop, "Loop")
hoverDesc(gui.bgplayer.all.scrollbar.controls.tempo, "Speed")

gui.bgplayer.all.controls.close.Activated:Connect(function()
	if not canint.check() then return end
	audtracker(nil)
end)

hoverDesc(gui.jam.close, "Minimize")

local function jamify(bool)
	task.delay(bool and 0 or 0.3, function()
		gui.jam.Visible = bool
	end)

	local AA, BB = bool and 0 or 1, bool and 1 or 0
	local CC, DD = bool and 0.5 or 1, bool and 1 or 0.5

	gui.jam.BackgroundTransparency = BB
	TWNs:Create(gui.jam, TweenInfo.new(0.3), {
		BackgroundTransparency = AA
	}):Play()
	gui.jam.all.icon.main.ImageTransparency = BB
	gui.jam.all.icon.main.BackgroundTransparency = BB
	TWNs:Create(gui.jam.all.icon.main, TweenInfo.new(0.3), {
		ImageTransparency = AA,
		BackgroundTransparency = AA
	}):Play()
	gui.jam.all.metadata.title.TextTransparency = BB
	TWNs:Create(gui.jam.all.metadata.title, TweenInfo.new(0.3), {
		TextTransparency = AA
	}):Play()
	gui.jam.all.metadata.id.TextTransparency = BB
	TWNs:Create(gui.jam.all.metadata.id, TweenInfo.new(0.3), {
		TextTransparency = AA
	}):Play()
	gui.jam.close.ImageTransparency = DD
	TWNs:Create(gui.jam.close, TweenInfo.new(0.3), {
		ImageTransparency = CC
	}):Play()

	script.linee.BackgroundTransparency = BB
	TWNs:Create(script.linee, TweenInfo.new(0.3), {
		BackgroundTransparency = AA
	}):Play()

	gui.jam.all.progress.current.TextTransparency = BB
	gui.jam.all.progress["end"].TextTransparency = BB
	TWNs:Create(gui.jam.all.progress.current, TweenInfo.new(0.3), {
		TextTransparency = AA
	}):Play()
	TWNs:Create(gui.jam.all.progress["end"], TweenInfo.new(0.3), {
		TextTransparency = AA
	}):Play()
	gui.jam.all.progress.line.BackgroundTransparency = DD
	TWNs:Create(gui.jam.all.progress.line, TweenInfo.new(0.3), {
		BackgroundTransparency = CC
	}):Play()
	gui.jam.all.progress.line.fill.BackgroundTransparency = BB
	TWNs:Create(gui.jam.all.progress.line.fill, TweenInfo.new(0.3), {
		BackgroundTransparency = AA
	}):Play()
end
local function doJam()
	canint.protect("jam")
	desc = nil
	jamify(true)
end

gui.bgplayer.all.controls.jam.Activated:Connect(function()
	if not canint.check() then return end

	doJam()
end)

gui.jam.close.Activated:Connect(function()
	if not canint.isprotect("jam") then return end
	canint.unprotect("jam")

	jamify(false)
end)

local auLooped = false
local loopControl = gui.bgplayer.all.scrollbar.controls.loop
local spotifyGreen = Color3.new(0.423529, 0.87451, 0.4)
local iconGray = Color3.new(0.760784, 0.760784, 0.760784)

loopControl.Activated:Connect(function()
	if not canint.check() then return end
	if not audplay then return end

	auLooped = not auLooped
end)

gui.bgplayer.all.scrollbar.controls.tempo.Activated:Connect(function()
	if not canint.check() then return end

	gui.bgplayer.other.tempo.Visible = not gui.bgplayer.other.tempo.Visible
end)

local tval = gui.bgplayer.other.tempo.value
local tbtn = gui.bgplayer.other.tempo.btn
tval:GetPropertyChangedSignal("Text"):Connect(function()
	local n = ""
	for _, x in pairs(tval.Text:split("")) do
		if x:match("%d") or x == "." then n ..= x end
	end

	tval.Text = n
end)
tval.FocusLost:Connect(function()
	local n = tonumber(tval.Text) or 1
	tval.Text = tostring(math.clamp(n, 0, 10))
end)

tval.Text = "1"

tbtn.MouseButton1Down:Connect(function()
	while not isReleased() do
		task.wait()
		local x = ((mouse.X-tbtn.AbsolutePosition.X)/tbtn.AbsoluteSize.X)*10

		tval.Text = math.floor(math.clamp(x, 0, 10)*100)/100
	end
end)

gui.bgplayer.all.scrollbar.controls.status.Activated:Connect(function()
	if not canint.check() then return end
	if not audplay then return end

	if audplay.IsPlaying then audplay:Pause()
	else audplay:Resume() end
end)

local songIsPlayingAt = false
game.ReplicatedStorage.events.tabs.audio.PlayedAt.OnClientEvent:Connect(function(tm)
	if tm then songIsPlayingAt = tick()
	else songIsPlayingAt = false end
end)

local function doAFilters(x)
	isfilt = x
	TWNs:Create(gui.filters, TweenInfo.new(0.18, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
		AnchorPoint = Vector2.new(x and 1 or 0, 1)
	}):Play()
end
doAFilters(false)

gui.bgplayer.all.controls.filters.Activated:Connect(function()
	if not audplay or not canint.check() then return end

	doAFilters(not isfilt)
end)

gui.bgplayer.all.controls.share.Activated:Connect(function()
	if not audplay or not canint.check() then return end

	gui.bgplayer.all.controls.share.ui.Visible = not gui.bgplayer.all.controls.share.ui.Visible
end)

gui.bgplayer.all.controls.share.ui.friends.Activated:Connect(function()
	if not audplay or not canint.check() then return end

	gui.bgplayer.all.controls.share.ui.Visible = false
	social:ShareSong(audplay:GetAttribute("id"))
end)
gui.bgplayer.all.controls.share.ui.copy.Activated:Connect(function()
	if not audplay or not canint.check() then return end

	gui.bgplayer.all.controls.share.ui.Visible = false
	toClipboard(social:GeneratePlayLink("play="..tostring(audplay:GetAttribute("id"))))
end)

audtracker = function(AD, elm)
	task.spawn(function()
		if audplay then audplay:Stop() end
		for _, e in pairs(evvs) do e:Disconnect() end

		if not AD then
			game.ReplicatedStorage.events.social.SongUpdate:FireServer("stopped")
			gui.bgplayer.other.tempo.Visible = false
			TWNs:Create(gui.bgplayer, TweenInfo.new(0.35, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				Position = UDim2.new(gui.bgplayer.Position.X.Scale, 0, 1, 0)
			}):Play()
			TWNs:Create(gui.container, TweenInfo.new(0.35, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				Position = UDim2.new(gui.container.Position.X.Scale, 0, gui.container.Position.Y.Scale, 0)
			}):Play()
			doAFilters(false)
			gui.bgplayer.all.controls.share.ui.Visible = false

			if audplay then audplay.Parent = game.ReplicatedStorage.sounds end
			songIsPlayingAt = nil
			audplay = AD
		else
			AD.Parent = workspace.Terrain.attach.attach
			game.ReplicatedStorage.events.social.SongUpdate:FireServer("played", AD.Name, AD.TimePosition)

			makeImageStuff(AD, gui.bgplayer.all.scrollbar.controls.status, gui.bgplayer.all.scrollbar.controls.status, "bgplayer")
			AD.Looped = auLooped

			if not elm:FindFirstChild("metadata") then return end
			gui.jam.all.metadata.title.Text = elm.metadata.title.Text
			gui.bgplayer.all.metadata.meta.title.Text = elm.metadata.title.Text
			gui.jam.all.metadata.id.Text = elm.metadata.id.Text
			gui.bgplayer.all.metadata.meta.id.Text = elm.metadata.id.Text
			gui.bgplayer.all.scrollbar.progress["end"].Text = makeTimer(AD.TimeLength)

			local hasmouse = false
			local actmouse = false
			table.insert(evvs, gui.bgplayer.all.scrollbar.progress.line.btn.MouseEnter:Connect(function()
				if not canint.check() then return end
				hasmouse = true
			end))
			table.insert(evvs, gui.bgplayer.all.scrollbar.progress.line.btn.MouseLeave:Connect(function()
				if not canint.check() then return end
				hasmouse = false
			end))
			table.insert(evvs, gui.bgplayer.all.scrollbar.progress.line.btn.MouseButton1Down:Connect(function(k)
				if not canint.check() then return end
				actmouse = true
				waitUntilRelease()
				actmouse = false
			end))

			local debounceTP
			table.insert(evvs, AD:GetPropertyChangedSignal("TimePosition"):Connect(function()
				local crap = math.floor(AD.TimePosition*100)/100
				if crap ~= debounceTP then
					debounceTP = crap
					game.ReplicatedStorage.events.social.PlaybUpdate:FireServer("time", crap)
				end
			end))
			local debouncePS
			table.insert(evvs, AD:GetPropertyChangedSignal("PlaybackSpeed"):Connect(function()
				local crap = math.floor(AD.PlaybackSpeed*100)/100
				if crap ~= debouncePS then
					debouncePS = crap
					game.ReplicatedStorage.events.social.PlaybUpdate:FireServer("speed", crap)
				end
			end))
			table.insert(evvs, AD:GetPropertyChangedSignal("Looped"):Connect(function()
				game.ReplicatedStorage.events.social.PlaybUpdate:FireServer("loop", AD.Looped)
			end))
			table.insert(evvs, AD.Resumed:Connect(function()
				game.ReplicatedStorage.events.social.SongUpdate:FireServer("played", AD.Name, AD.TimePosition)
			end))
			table.insert(evvs, AD.Played:Connect(function()
				game.ReplicatedStorage.events.social.SongUpdate:FireServer("played", AD.Name, AD.TimePosition)
			end))
			table.insert(evvs, AD.Paused:Connect(function()
				game.ReplicatedStorage.events.social.SongUpdate:FireServer("paused")
			end))
			table.insert(evvs, AD.Ended:Connect(function()
				if AD.Looped then return end
				game.ReplicatedStorage.events.social.SongUpdate:FireServer("paused")
			end))
			table.insert(evvs, AD.DidLoop:Connect(function()
				if AD.Looped then return end
				game.ReplicatedStorage.events.social.SongUpdate:FireServer("played", AD.Name, AD.TimePosition)
			end))

			local inf = TweenInfo.new(0.1, Enum.EasingStyle.Sine)
			audplay = AD
			task.spawn(function()
				while audplay == AD do
					if hasmouse or actmouse then
						local ff = (mouse.X - gui.bgplayer.all.scrollbar.progress.line.AbsolutePosition.X)/gui.bgplayer.all.scrollbar.progress.line.AbsoluteSize.X
						local post = math.max(math.min(ff, 1), 0)

						gui.bgplayer.all.scrollbar.progress.current.Text = makeTimer(AD.TimeLength*post)
						TWNs:Create(gui.bgplayer.all.scrollbar.progress.line.fill, inf, { Size = UDim2.new(post, 0, 1, 0) }):Play()
						if actmouse then AD.TimePosition = AD.TimeLength*post end
						if actmouse and not AD.IsPlaying then AD:Resume() end
					else
						gui.bgplayer.all.scrollbar.progress.current.Text = makeTimer(AD.TimePosition)
						TWNs:Create(gui.bgplayer.all.scrollbar.progress.line.fill, inf, { Size = UDim2.new(AD.TimePosition/AD.TimeLength, 0, 1, 0) }):Play()
					end
					task.wait()
				end
			end)

			TWNs:Create(gui.bgplayer, TweenInfo.new(0.35, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
				Position = UDim2.new(gui.bgplayer.Position.X.Scale, 0, 0.9, 0)
			}):Play()
			TWNs:Create(gui.container, TweenInfo.new(0.35, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
				Position = UDim2.new(gui.container.Position.X.Scale, 0, gui.container.Position.Y.Scale, -gui.bgplayer.AbsoluteSize.Y)
			}):Play()
		end
	end)
end

local maus = "ArrowFar"
local alreadyhover = false

local function checkThingg(ZL)
	if ZL.Name == "clickCircle" then return end
	local isclick = ZL:IsA("TextButton") or ZL:IsA("ImageButton")
	local istext = ZL:IsA("TextBox")
	if not isclick and not istext then return end

	local function parentCheck()
		local yaas = true
		local now = ZL
		for i = 1, 10 do
			if not now then break end

			pcall(function()
				if not ZL.Visible then yaas = false end
			end)

			if not yaas then break end
			now = now.Parent
		end

		return yaas
	end

	pcall(function()
		ZL.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseMovement then
				if not parentCheck() then return end
				alreadyhover = ZL

				if not canint.check(ZL:GetAttribute("canint")) then
					repeat task.wait() until canint.check() or alreadyhover ~= ZL
					if alreadyhover ~= ZL then return end
				end

				if isclick then maus = "Arrow"
				elseif istext then maus = "IBeam"
				else maus = "ArrowFar" end
			end
		end)
		ZL.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseMovement then
				if not parentCheck() then return end

				task.wait()
				if alreadyhover == ZL then maus = "ArrowFar" end
				alreadyhover = false
			end
		end)
	end)
end

for _, elm in pairs(gui:GetDescendants()) do
	checkThingg(elm)
end
gui.DescendantAdded:Connect(checkThingg)

local gbadge = false
local blockAll = false
local blockAll2 = false
local contBG = Color3.fromRGB(23, 24, 40)
local doOsu = false

local audAffect = {
	tempo = true,
	pitch = true
}
local oldstuff = ""

local oldpbs = 1
local customVevent = Instance.new("NumberValue")
customVevent.Value = 0

local baudios = require(game.ReplicatedStorage.modules.blockAudios)
local function matchUndertale(str)
	for _, x in pairs(baudios.undertale) do
		if str:lower():find(x) then return true end
	end
end

local ojps = 0
local jamwaveform = false
local toloaded = 0
local toload = math.huge
local toloadGiveup = false

local spunStart = tick()

local BT, BThavr = gui.navbar.settings.beta, false
BT.MouseEnter:Connect(function()
	if BThavr then return end
	BThavr = true

	local incr = 2.5
	while BThavr and RNs.RenderStepped:Wait() do
		incr *= 1.02
		local rot = BT.Rotation + incr
		rot -= math.floor(rot/360)*360

		BT.Rotation = rot
	end
	TWNs:Create(BT, TweenInfo.new(0.66, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Rotation = 0
	}):Play()
end)
BT.MouseLeave:Connect(function()
	BThavr = false
end)
hoverDesc(BT, "Use /main to return to main version!")

RNs.RenderStepped:Connect(function(dt)
	pcall(function()
		for _, x in pairs(Enum.CoreGuiType:GetEnumItems()) do
			if x.Name == "All" or x.Name == "SelfView" then continue end
			local value = x.Name == "Chat"
			if blockAll or blockAll2 then value = false end
			game.StarterGui:SetCoreGuiEnabled(x, value)
		end
		game.StarterGui:SetCore("TopbarEnabled", true)
	end)

	if gui.AbsoluteSize.Y > gui.AbsoluteSize.X*1.13 then
		gui.portrait.Visible = true
		blockAll2 = true
		canint.protect("portrait")
	else
		blockAll2 = false
		gui.portrait.Visible = false
		canint.unprotect("portrait")
	end

	if not gui.Enabled then
		game.ReplicatedStorage.events["Get Exploiter Badge"]:FireServer("gui wasn't enabled")
		gui.Enabled = true
	end

	doubleclickRT = UIs.TouchEnabled and 0.55 or 0.3
	slideprevRT = UIs.TouchEnabled and 20 or 13

	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = workspace.Terrain.attach.CFrame

	gui.navbar.settings.beta.Visible = workspace.data.server.beta.Value

	local rot = gui.teleporting.icon.icon.Rotation
	if rot >= 360 then rot -= 360 end
	gui.teleporting.icon.icon.Rotation = rot+3

	-- obsessed badge tracker
	if songIsPlayingAt and audplay then
		local range = audplay.PlaybackSpeed/10
		-- grrr stupid roblox thing
		range *= dt / (1/60)

		audplay:SetAttribute("tim", (audplay:GetAttribute("tim") or 0) + range)

		local slay = math.sin(audplay:GetAttribute("tim") * 1.1)*0.1

		gui.obsessed.icon.soul.Position = UDim2.new(0.5, 0, 0.5+slay, 0)

		gui.obsessed.Visible = true
		gui.obsessed.time.Text = makeTimer(math.floor(tick()-songIsPlayingAt))

		if audplay and matchUndertale(audplay:GetAttribute("name")) then
			gui.obsessed.icon.soul.Visible = true
			gui.obsessed.icon.ImageTransparency = 1
		else
			gui.obsessed.icon.soul.Visible = false
			gui.obsessed.icon.ImageTransparency = 0.85
		end
	else
		gui.obsessed.Visible = false
	end

	-- groove battle (very useful)
	local gbattle = script.sfx["groove battle"]
	if gui.container.about.Visible then
		local groovy = gui.container.about.f2.figure
		local hello = math.max(gui.AbsoluteSize.Y-groovy.AbsolutePosition.Y, 0)
		local yo = (hello/gui.AbsoluteSize.Y)*1.2
		gbattle.Volume = yo

		if gbattle.Volume > 0.65 and not gbadge then
			gbadge = true
			game.ReplicatedStorage.events.tabs.about.GBattle:FireServer()
		end
	else
		gbattle.Volume = 0
	end

	-- scrolling frame
	for _, bo in pairs(gui:GetDescendants()) do
		if bo:IsA("ScrollingFrame") then
			local onb = canint.check(bo:GetAttribute("canint"))
			bo.ScrollingEnabled = onb
		end
	end

	-- status
	gui.bgplayer.other.status.Text = workspace.data.server.rstatus.Value

	-- mouse icon thing
	UIs.MouseIconEnabled = false
	damouse.Image = `rbxasset://textures/Cursors/KeyboardMouse/{maus}Cursor.png`
	damouse.Visible = UIs.MouseEnabled
	damouse.Position = UDim2.new(0, mouse.X, 0, mouse.Y+36)

	-- audplay stuff
	--- loop
	loopControl.ImageColor3 = auLooped and spotifyGreen or iconGray
	if audplay then
		audplay.Looped = auLooped
	end

	--- tempo
	local bam = tonumber(gui.bgplayer.other.tempo.value.Text) or 1
	bam = math.max(math.min(bam, 10), 0)
	gui.bgplayer.all.scrollbar.controls.tempo.ImageColor3 = bam ~= 1 and spotifyGreen or iconGray
	gui.bgplayer.other.tempo.line.Position = UDim2.new(bam/10, 0, 0, 0)

	local enableSpeedChange = audAffect.tempo
	local enablePSSChange = (not audAffect.pitch and audAffect.tempo) or (audAffect.pitch and not audAffect.tempo)

	if audplay then audplay.PlaybackSpeed = enableSpeedChange and bam or 1 end

	local trck = ""
	if audAffect.pitch then trck..="P" end
	if audAffect.tempo then trck..="T" end

	if oldpbs ~= bam or oldstuff ~= trck then
		game.SoundService.listAudio.speedPitch:ClearAllChildren()
		if bam ~= 0 then
			local change = audAffect.tempo and (1/bam) or bam

			if change < 1 then
				while true do
					local todo = change
					local maxOut = false
					if todo < 0.5 then todo = 0.5; change /= 0.5; maxOut = true end

					local pitch = Instance.new("PitchShiftSoundEffect", game.SoundService.listAudio.speedPitch)
					pitch.Octave = todo
					pitch.Enabled = todo ~= 1

					if not maxOut then break end
				end
			elseif change > 1 then
				while true do
					local todo = change
					local maxOut = false
					if todo > 2 then todo = 2; change /= 2; maxOut = true end

					local pitch = Instance.new("PitchShiftSoundEffect", game.SoundService.listAudio.speedPitch)
					pitch.Octave = todo
					pitch.Enabled = todo ~= 1

					if not maxOut then break end
				end
			end
		end
	end
	oldpbs = bam
	oldstuff = trck

	for _, x in pairs(game.SoundService.listAudio.speedPitch:GetChildren()) do
		x.Enabled = x.Octave == 1 and (false) or enablePSSChange
	end

	-- hover stuff
	if desc and desc[1] and desc[2] then
		local AY = gui.AbsoluteSize.Y * 0.044
		local tbx = TXTs:GetTextSize(desc[2], AY, gui.desc.Font.Name, Vector2.new(9999, 9999))
		if tbx.X >= gui.AbsoluteSize.X then
			AY = gui.AbsoluteSize.Y * 0.033
			tbx = TXTs:GetTextSize(desc[2], AY, gui.desc.Font.Name, Vector2.new(9999, 9999))
			if tbx.X >= gui.AbsoluteSize.X then
				AY = gui.AbsoluteSize.Y * 0.022
				tbx = TXTs:GetTextSize(desc[2], AY, gui.desc.Font.Name, Vector2.new(9999, 9999))
			end
		end

		gui.desc.Size = UDim2.new(UDim.new(0, tbx.X), UDim.new(0, tbx.Y))
		gui.desc.Text = desc[2]
		gui.desc.Position = UDim2.new(
			0, math.min(mouse.X, gui.AbsoluteSize.X-gui.desc.AbsoluteSize.X),
			0, math.min(mouse.Y, gui.AbsoluteSize.Y-gui.desc.AbsoluteSize.Y)
		)
		gui.desc.Visible = true
	else
		gui.desc.Visible = false
	end

	sn += 0.04
	local A = math.sin(sn*1.5)*4
	local B = math.sin(sn*2)*3
	local C = math.sin(sn*2)*2
	local D = math.sin(sn*1.5)*2
	local E = math.sin(sn*1.5)*4
	local F = math.sin(sn*2)*2
	local G = math.sin(sn*2)*4
	local H = math.sin(sn*1.5)*2

	local ds = {A,B,C,D,E,F,G,H}
	local positions = {}

	for i = 1, #ds, 2 do
		local px = Vector3.new(ds[i], (ds[i]+ds[i+1])/2, ds[i+1])
		table.insert(positions, px)
	end

	gui.loading:ClearAllChildren()

	for i, h in pairs(positions) do
		local D = script.dot:Clone()
		D.Position = h
		D.Parent = gui.loading
	end

	local function makeLine(D1, D2)
		local ln = script.lin:Clone()
		ln.Parent = gui.loading
		local sz = ln.Size
		ln.Size = Vector3.new(sz.X, sz.Y, (D1-D2).Magnitude)
		ln.CFrame = CFrame.new((D1+D2)/2, D2)
	end

	local post = {}
	for _, p1 in pairs(positions) do
		for _, p2 in pairs(positions) do
			if table.find(post, {p1, p2}) or table.find(post, {p2, p1}) then continue end
			table.insert(post, {p1, p2})
			makeLine(p1, p2)
		end
	end

	gui.loading.CurrentCamera = cam
	cam.CFrame = CFrame.new(Vector3.new(0, 15, 0), Vector3.new())*CFrame.Angles(0, 0, math.rad(rt))
	rt += 1

	local doframe = math.floor(customVevent.Value)
	local Gsize = gui.bgplayer.other.custom.ImageRectSize
	local grid = gui.bgplayer.other.custom.grid.Value
	gui.bgplayer.other.custom.ImageRectOffset = Vector2.new(
		(doframe%grid)*Gsize.X,
		math.floor(doframe/grid)*Gsize.Y
	)

	gui.visualizer.Visible = true
	if audplay then
		local loudness = audplay.PlaybackLoudness
		for _, g in pairs(gui.visualizer.bars:GetChildren()) do
			if g:IsA("Frame") then
				local perc = loudness/1500
				TWNs:Create(g, TweenInfo.new(0.1), {
					Size = UDim2.new(g.Size.X, UDim.new(loudness/900+math.random(perc*100, perc*150)/100, 0))
				}):Play()
			end
		end

		local customStages = gui.bgplayer.other.custom.stages.Value
		local splitter = 500/customStages
		local frame = math.min(math.floor(loudness/splitter), customStages-1)

		TWNs:Create(customVevent, TweenInfo.new(0.15), {
			Value = frame
		}):Play()
		TWNs:Create(gui.bgplayer.other.custom, TweenInfo.new(0.1), {
			ImageTransparency = 0
		}):Play()
	else
		for _, g in pairs(gui.visualizer.bars:GetChildren()) do
			if g:IsA("Frame") then
				TWNs:Create(g, TweenInfo.new(1), {
					Size = UDim2.new(g.Size.X, UDim.new())
				}):Play()
			end
		end
		TWNs:Create(gui.bgplayer.other.custom, TweenInfo.new(1), {
			ImageTransparency = 1
		}):Play()
	end

	-- HI
	local poss = 16 + 32 + 12
	local hasChat = game.StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat)

	if hasChat then poss += 32 + 12 end

	gui.topbar.frame.Position = UDim2.new(0, poss, 0, 0)
	gui.topbar.frame.Size = UDim2.new(0.5, -poss, 1, 0)
end)

local function updateSocialList(target, sdata)
	if target == "global" then
		local yas = {}
		for _, ys in pairs(sdata) do
			yas[#yas+1] = `@{ys.user.name} - {ys.doing.tab}{ys.doing.song and ` {ys.doing.songPlaying and "▶" or "⏸"} {ys.doing.song}` or ""}`
		end
	end
end
game.ReplicatedStorage.events.social.Updated.OnClientEvent:Connect(updateSocialList)

local TBisHover = false
local TBisActive = false

local function TBupdate()
	gui.topbar.frame.social.background.stateoverlay.ImageColor3 = TBisActive and Color3.new() or Color3.new(1, 1, 1)
	gui.topbar.frame.social.background.stateoverlay.ImageTransparency = TBisActive and 0.7 or TBisHover and 0.9 or 1
end

gui.topbar.frame.social.background.InputBegan:Connect(function(k)
	if k.UserInputType == Enum.UserInputType.MouseMovement then
		TBisHover = true
	elseif isInput(k) then
		TBisActive = true
	end

	TBupdate()
end)
gui.topbar.frame.social.background.InputEnded:Connect(function(k)
	if k.UserInputType == Enum.UserInputType.MouseMovement then
		TBisHover, TBisActive = false, false
	elseif isInput(k) then
		TBisActive = false
	end

	TBupdate()
end)

local invr = false
local lastJW = 1
local jvw = 0
local baseDelta = 1/60
RNs.RenderStepped:Connect(function(delta)
	-- jam
	local howl = delta/baseDelta
	if audplay then
		local value = (audplay.PlaybackLoudness/800)
		local s = 0.9+value*0.3
		local bgC = {gui.jam.BackgroundColor3:ToHSV()}
		local bgV = 0.0784+value*0.15
		local info = TweenInfo.new(0.05, Enum.EasingStyle.Quad)
		TWNs:Create(gui.jam, info, {
			BackgroundColor3 = Color3.fromHSV(bgC[1], bgC[2], invr and 1-bgV or bgV)
		}):Play()
		TWNs:Create(gui.jam.all.icon.main, info, {
			Size = UDim2.new(s, 0, s, 0)
		}):Play()

		if audplay.IsPlaying then gui.jam.all.icon.main.Rotation += audplay.PlaybackSpeed+0.5*howl end

		gui.jam.all.progress.current.Text = makeTimer(audplay.TimePosition)
		gui.jam.all.progress["end"].Text = makeTimer(audplay.TimeLength)
		gui.jam.all.progress.line.fill.Size = UDim2.new(audplay.TimePosition/audplay.TimeLength, 0, 1, 0)

		if jamwaveform then
			jvw += howl

			local val = audplay.PlaybackLoudness / 888
			val = 1-(math.floor(val*1000)/1000)

			local width, height = gui.jam.waveform.AbsoluteSize.X, gui.jam.waveform.AbsoluteSize.Y
			local Cbef = Vector2.new(0, lastJW*height)
			local Cval = Vector2.new(howl*14, val*height)
			local Cdif = Cval-Cbef
			local Cmid = (Cval+Cbef)/2
			local Crot = math.atan(Cdif.Y / Cdif.X)

			lastJW = val

			local lan = script.linee:Clone()
			lan.Name = tostring(jvw)
			lan.Rotation = math.deg(Crot)
			lan.Size = UDim2.new(0, Cdif.Magnitude, 0, 6)
			lan:SetAttribute("y", Cmid.Y/height)
			lan:SetAttribute("ord", jvw)
			lan:SetAttribute("siz", howl*14)
			lan.Parent = gui.jam.waveform

			local lifetime
			local counter = 0
			lifetime = RNs.RenderStepped:Connect(function()
				if not lan.Parent then return lifetime:Disconnect() end

				counter += 1

				if counter >= 300 then
					lan:Destroy()
				end
			end)

			for _, x in pairs(gui.jam.waveform:GetChildren()) do
				if x:IsA("Frame") then
					local Y = x:GetAttribute("y")
					local ord = x:GetAttribute("ord")
					local siz = x:GetAttribute("siz")
					local offset = (jvw - ord) * 14

					x.Position = UDim2.new(1, -offset - siz/2, Y, -3)
					x.BackgroundTransparency = script.linee.BackgroundTransparency
				end
			end
		else
			for _, x in pairs(gui.jam.waveform:GetChildren()) do
				if x:IsA("Frame") then x:Destroy() end
			end
			jvw = 0
			lastJW = 1
		end
	end
end)

local function slayd(gr, vld)
	TWNs:Create(gr, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
		Value = vld
	}):Play()
end

local blockkeys = {}
for k, _ in pairs(baudios) do table.insert(blockkeys, k) end

local function dropdownElement(e, list, runAfter, hoe, runFirst, tag)
	if not e:FindFirstChild("UIListLayout") then
		local g = script.optionList:Clone()
		g.Name = "UIListLayout"
		g.Parent = e
	end

	if runAfter and runFirst then
		runAfter(list[1])
	end

	local hasElements = false
	e.MouseButton1Click:Connect(function()
		if hasElements then return end
		if not canint.check() and not canint.isprotect(tag) then return end
		local j

		if hoe > 0 then
			j = e
			for i = 1, hoe do
				j.ZIndex = 2
				j = j.Parent
			end
		end

		hasElements = true
		local btns, evs = {}, {}
		local response
		for _, x in pairs(list) do
			local o = script.option:Clone()
			o.Name = x
			o.btn.Text = x
			o.Parent = e
			table.insert(evs, o.btn.Activated:Connect(function()
				if not canint.check() and not canint.isprotect(tag) then return end
				response = x
			end))
			table.insert(btns, o)
		end

		local ev = UIs.InputBegan:Connect(function(k)
			if not canint.check() and not canint.isprotect(tag) then return end
			if isInput(k) then
				task.wait(inputBeganThingy)
				response = false
			end
		end)
		repeat task.wait() until response ~= nil
		hasElements = false

		if hoe > 0 then
			j = e
			for i = 1, hoe do
				j.ZIndex = 1
				j = j.Parent
			end
		end

		ev:Disconnect()
		for _, o in pairs(btns) do o:Destroy() end
		for _, eV in pairs(evs) do eV:Disconnect() end

		if response then
			runAfter(response)
		end
	end)
end

local filters = {
	show = "everything",
	sort = true,
	creator = plr.Name,
	popularRange = "all"
}
local function setFC()
	local h = HTTPs:GenerateGUID(false)
	filters.check = h
end
setFC()

RNs.RenderStepped:Connect(function()
	for _, x in pairs(gui.container.audios.searching.left.types:GetChildren()) do
		if x:IsA("ImageButton") then
			x.ImageTransparency = filters.show == x.Name and 0 or 0.6
		end
	end
	gui.container.audios.searching.left.sorting.new.ImageTransparency = filters.sort and 0 or 0.6
	gui.container.audios.searching.left.sorting.old.ImageTransparency = filters.sort and 0.6 or 0

	gui.container.audios.searching.left.creator.Visible = filters.show == "creator"
	gui.container.audios.searching.left.popular.Visible = filters.show == "popular"

	gui.container.audios.searching.left.popular.dropdown.Text =
		filters.popularRange == "all"
			and "All Time" or
		filters.popularRange == "week"
			and "This Week" or
		filters.popularRange == "day"
			and "This Day" or
		filters.popularRange == "hour"
			and "This Hour"
end)

for _, x in pairs(gui.container.audios.searching.left.types:GetChildren()) do
	if x:IsA("ImageButton") then
		if not x.Visible then continue end
		x.Activated:Connect(function()
			if filters.show == x.Name then return end
			filters.show = x.Name

			setFC()
		end)
	end
end
gui.container.audios.searching.left.sorting.new.Activated:Connect(function()
	if filters.sort then return end
	filters.sort = true

	setFC()
end)
gui.container.audios.searching.left.sorting.old.Activated:Connect(function()
	if not filters.sort then return end
	filters.sort = false

	setFC()
end)

hoverDesc(gui.container.audios.searching.left.types.everything, "Everything")
hoverDesc(gui.container.audios.searching.left.types.favorites, "Favorites")
hoverDesc(gui.container.audios.searching.left.types.creator, "Creator")
hoverDesc(gui.container.audios.searching.left.types.history, "History")

hoverDesc(gui.container.audios.searching.left.sorting.new, "Newest (Descending)")
hoverDesc(gui.container.audios.searching.left.sorting.old, "Oldest (Ascending)")

gui.container.audios.searching.left.creator.value.Text = plr.Name
gui.container.audios.searching.left.creator.value.FocusLost:Connect(function()
	filters.creator = gui.container.audios.searching.left.creator.value.Text

	setFC()
end)
dropdownElement(gui.container.audios.searching.left.popular.dropdown, {"All Time", "This Week", "This Day", "This Hour"}, function(response)
	if response == "All Time" then filters.popularRange = "all"
	elseif response == "This Week" then filters.popularRange = "week"
	elseif response == "This Day" then filters.popularRange = "day"
	elseif response == "This Hour" then filters.popularRange = "hour" end
	setFC()
end, 2)

local firstAud = true

local myData = dataGetter:MakeTemplateData()
local queuedChangelog = false
local function modUpdated(data)
	myData = data
	local readTos = data.track.tosLast == workspace.data.game.lastTos.Value

	for _, s in pairs(gui.container.audios.list:GetChildren()) do
		local link = game.ReplicatedStorage.sounds:FindFirstChild(s.Name)
		if not link then continue end

		s.controls.favorite.ImageTransparency = data.favorites[tostring(link:GetAttribute("id"))] and 0 or 0.5
	end

	if not readTos then
		canint.protect("tos")
		gui.tos.Visible = true
		gui.tos.BackgroundTransparency = 0.5
		gui.tos.frame.Size = UDim2.new(0.55, 0, 0.8, 0)
	else
		TWNs:Create(gui.tos.frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new()
		}):Play()
		TWNs:Create(gui.tos, TweenInfo.new(0.5), {
			BackgroundTransparency = 1
		}):Play()
		task.delay(0.6, function()
			gui.tos.Visible = false
			canint.unprotect("tos")
			canint.unprotect("tosagree")
		end)

		if not queuedChangelog then
			queuedChangelog = true
		--	repeat task.wait() until canint.check()
		--	changelog.check(data.track.changelog)
		--	game.ReplicatedStorage.events.tracking.UpdateSettings:FireServer("changelog")
		end
	end

	for _, x in pairs(gui.navbar:GetChildren()) do
		if x:IsA("Frame") then x.Visible = readTos or x.Name == "about" end
	end
end
game.ReplicatedStorage.events.tracking.UpdateSettings.OnClientEvent:Connect(modUpdated)

task.spawn(function()
	repeat task.wait() until canint.check("tos")
	task.wait()

	local tw = TWNs:Create(gui.tos.frame.agree.agree.bg, TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	})
	tw:Play()
	tw.Completed:Wait()
	gui.tos.frame.agree.agree.AutoButtonColor = true
	gui.tos.frame.agree.agree.text.TextTransparency = 0.3
	gui.tos.frame.agree.agree.Activated:Connect(function()
		if not canint.check("tos") then return end
		canint.protect("tosagree")
		game.ReplicatedStorage.events.tracking.UpdateSettings:FireServer("tosLast")
	end)
end)

local badgeCache = {}
local usernamecache = {}
local second = true
local gassets = {}

local tempBadge = {
	name = "N/A",
	displayIconImageId = 123,
	statistics = {
		awardedCount = 123
	},
	owns = false
}
local function cacheBadge(id)
	if badgeCache[id] then return badgeCache[id] or tempBadge end

	local d = game.ReplicatedStorage.events.tabs.badges.GetInfo:InvokeServer(tostring(id))
	local scs, owns = pcall(function()
		return BDGs:UserHasBadgeAsync(plr.UserId, id)
	end)
	d.owns = scs and owns
	badgeCache[id] = d
	return d or tempBadge
end

local ABadges = require(game.ReplicatedStorage.modules.Badges)
task.spawn(function()
	for id in pairs(ABadges) do
		cacheBadge(id)
	end
end)

local function loadSongUI(a, l, sond)
	local function ohyeah()
		if not canint.check() then return end
		toClipboard(tostring(a.id))
	end
	l.Name = tostring(a.id)
	l.controls.favorite.ImageTransparency = myData.favorites[tostring(a.id)] and 0 or 0.5

	hoverDesc(l.controls.favorite, function()
		if isfilt then return end
		return myData.favorites[tostring(a.id)] and "Unfavorite" or "Favorite"
	end)
	l.controls.favorite.Activated:Connect(function()
		if isfilt then return end
		game.ReplicatedStorage.events.tracking.UpdateSettings:FireServer("favorite", a.id, not myData.favorites[tostring(a.id)])
	end)

	l.metadata.title.Text = a.name

	local txt = a.log and `{a.id} (@{a.log.user.name}{a.log.user.verified and ` {unicode.verified}` or ""})` or a.id

	l.metadata.id.Text = txt
	l.icon.hitbox.MouseButton2Click:Connect(ohyeah)
	l.icon.hitbox.TouchLongPress:Connect(ohyeah)

	local rasand = game.ReplicatedStorage:FindFirstChild(tostring(a.id))
	if rasand then sond:Destroy(); sond = rasand
	else
		sond:SetAttribute("id", a.id)
		sond:SetAttribute("name", a.name)
		if a.log then
			sond:SetAttribute("log", HTTPs:JSONEncode(a.log))
		end
		sond.Name = a.id
		sond.SoundGroup = game.SoundService.listAudio.speedPitch
		sond.SoundId = "rbxassetid://"..a.id
	end

	return l, sond
end

local function newSound()
	local sound = Instance.new("Sound", game.ReplicatedStorage.sounds)
	sound.RollOffMaxDistance = 99999999
	sound.RollOffMinDistance = 99999998
	return sound
end

local function whenHolding(x, fnc, onStop)
	local holding

	x.InputBegan:Connect(function(y)
		if isInput(y) and canint.check() then
			local og, shouldMove
			holding = RNs.RenderStepped:Connect(function(...)
				if not og then og = Vector2.new(mouse.X, mouse.Y) end

				if not shouldMove then
					local new = Vector2.new(mouse.X, mouse.Y)
					if (new - og).Magnitude >= slideprevRT then shouldMove = true
					else return end
				end

				fnc(...)
			end)
		end
	end)
	x.InputEnded:Connect(function(x)
		if isInput(x) then
			if holding then holding:Disconnect(); holding = nil end
			if onStop then onStop() end
		end
	end)
end
local function whenDoubleclick(x, fnc)
	local latest = math.huge
	local lmao = 0

	x.InputBegan:Connect(function(y)
		if isInput(y) and canint.check() then
			if tick() >= latest then lmao = 0 end
			lmao += 1
			latest = tick()+doubleclickRT

			if lmao >= 2 then
				lmao = 0
				latest = 0
				fnc()
			end
		end
	end)
end

local function sliderIfy(elm, style, fnc, border)
	border = border or elm
	local vertical = style == "BT" or style == "TB"
	whenHolding(elm, function()
		local val
		if vertical then
			val = (mouse.Y-border.AbsolutePosition.Y)/(border.AbsoluteSize.Y)
		else
			val = (mouse.X-border.AbsolutePosition.X)/(border.AbsoluteSize.X)
		end

		val = math.clamp(val, 0, 1)

		if style == "BT" or style == "RL" then val = 1-val end

		fnc(val)
	end)
end

local afilters = {
	reverb = 0,
	bass = 0.5,
	space = "0D",
	spaceVal = 0,
	autoSpaceVal = true
}

local function getAFilterS3D()
	return math.sin(afilters.spaceVal * math.pi * 2)
end
local function getAFilterS8D()
	return Vector2.new(
		math.cos(afilters.spaceVal * math.pi * 2),
		math.sin(afilters.spaceVal * math.pi * 2)
	)
end

RNs.RenderStepped:Connect(function(del)
	local mult = del / (1/60)
	if afilters.autoSpaceVal then
		afilters.spaceVal += 0.005*mult
		if afilters.spaceVal >= 1 then afilters.spaceVal -= 1 end
	end

	gui.filters.reverb.slider.volume.Position = UDim2.new(afilters.reverb, 0, 0.5, 0)
	game.SoundService.listAudio.reverb.DryLevel = afilters.reverb * -20
	game.SoundService.listAudio.reverb.WetLevel = (1-afilters.reverb) * -20

	gui.filters.space_choose.Text = afilters.space
	local add = afilters.space ~= "0D" and " Double click speakers to input custom value." or ""
	local lines = afilters.space == "0D" and 1 or 2
	gui.filters.space_hint.Text = `Plays audio in {afilters.space} space.{add}`
	gui.filters.space_hint.Size = UDim2.new(1, 0, 0.03*lines, 0)

	for _, x in pairs(gui.filters.space:GetChildren()) do
		if x:IsA("Frame") then
			x.Visible = x.Name == afilters.space
		end
	end

	gui.filters.space["3D"].value.Position = UDim2.new(0.5 + (getAFilterS3D()/2 * 0.7), 0, 0.5, 0)
	gui.filters.space["8D"].value.Position = UDim2.new(0.5 + getAFilterS8D().X/2, 0, 0.5 + getAFilterS8D().Y/2, 0)

	local apos = Vector3.new()
	if afilters.space == "3D" then
		apos = Vector3.new(
			getAFilterS3D()*2,
			math.abs(2-(getAFilterS3D()*2)),
			0
		)
	elseif afilters.space == "8D" then
		apos = Vector3.new(
			getAFilterS8D().X*2,
			0,
			getAFilterS8D().Y*2
		)
	end
	workspace.Terrain.attach.attach.Position = apos

	local highMidG, lowG = 0, 0
	highMidG = -((afilters.bass - 0.5)*4)
	if afilters.bass > 0.5 then
		lowG = (afilters.bass - 0.5)*40
	else
		lowG = (afilters.bass - 0.5)*160
	end

	gui.filters.bass.slider.volume.Position = UDim2.new(afilters.bass, 0, 0.5, 0)
	game.SoundService.listAudio.equalizer.HighGain = highMidG
	game.SoundService.listAudio.equalizer.LowGain = lowG
	game.SoundService.listAudio.equalizer.MidGain = highMidG
end)

whenDoubleclick(gui.filters.reverb.slider.hitbox, function()
	afilters.reverb = 0
end)
sliderIfy(gui.filters.reverb.slider.hitbox, "LR", function(val)
	afilters.reverb = val
end, gui.filters.reverb.slider.line)

whenDoubleclick(gui.filters.bass.slider.hitbox, function()
	afilters.bass = 0.5
end)
sliderIfy(gui.filters.bass.slider.hitbox, "LR", function(val)
	afilters.bass = val
end, gui.filters.bass.slider.line)

dropdownElement(gui.filters.space_choose, {"0D", "3D", "8D"}, function(val)
	afilters.space = val
end, 0)
local space3D = gui.filters.space["3D"]
sliderIfy(space3D.hitbox, "LR", function(val)
	if afilters.autoSpaceVal then return end

	afilters.spaceVal = val
end, space3D.line)
local space8D = gui.filters.space["8D"]
whenHolding(space8D.hitbox, function()
	if afilters.autoSpaceVal then return end

	local pos = space8D.line.AbsolutePosition
	local siz = space8D.line.AbsoluteSize
	local mid = pos+siz/2

	local deg = (math.pi - math.atan2(mouse.Y - mid.Y, mid.X - mouse.X)) / (math.pi*2)

	afilters.autoSpaceVal = false
	afilters.spaceVal = math.clamp(deg, 0, 1)
end)

whenDoubleclick(space3D.hitbox, function()
	afilters.autoSpaceVal = not afilters.autoSpaceVal
end)
whenDoubleclick(space8D.hitbox, function()
	afilters.autoSpaceVal = not afilters.autoSpaceVal
end)

local jevs = {}
local firstTab = true
local latestContainer
local function selectContainer(e, noPopup)
	for _, s in pairs(game.ReplicatedStorage.sounds:GetChildren()) do if s ~= audplay then s:Destroy() end end
	for _, g in pairs(gui.container.audios.list:GetChildren()) do if g:GetAttribute("yes") then g:Destroy() end end
	for _, g in pairs(gui.container.leaderboard.list:GetChildren()) do if g:GetAttribute("yes") then g:Destroy() end end
	--TODO: donate
	--for _, g in pairs(gui.container.donate.items:GetChildren()) do if g:GetAttribute("yes") then g:Destroy() end end
	for _, g in pairs(gui.container.badges.container.badges.badges:GetChildren()) do if g:GetAttribute("yes") then g:Destroy() end end
	gui.container.audios.searching.left.search.Text = ""
	gui.container.about.CanvasPosition = Vector2.new()
	gui.container.badges.container.badges.label.Text = ""
	gui.container.badges.container.info.ws.Visible = false
	gui.container.badges.container.info.image.Visible = false
	gui.container.badges.container.info.title.Visible = false
	gui.container.badges.container.info.rarity.Visible = false
	gui.container.badges.container.info.desc.Visible = false

	-- epic troll xD
	if Random.new():NextInteger(1, 100) == 10 then
		local trolly = script["epic troll"]:Clone()
		local captions = ("it knows what you did.|it lurks in the shadows.|it's behind you.|it knows your every move.|it knows you're a furry.|it knows you like boys kissing."):split("|")
		trolly.caption.Text = captions[math.random(1, #captions)]
		trolly.Parent = gui
		task.spawn(function()
			for i = 1, 2 do RNs.RenderStepped:Wait() end
			trolly:Destroy()
		end)
	end

	for _, x in pairs(jevs) do
		x:Disconnect()
	end
	gui.container.badges.container.info.people.Visible = false

	local nm = e == "badges" and 1 or 0
	TWNs:Create(gui.bgplayer.other.custom, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.new(nm, 0, 0, 0),
		AnchorPoint = Vector2.new(nm, 1)
	}):Play()

	if not firstTab then
		game.ReplicatedStorage.events.social.TabUpdate:FireServer(e)
	end

	for _, x in pairs(gui.navbar:GetChildren()) do
		if x:IsA("Frame") then
			TWNs:Create(x, TweenInfo.new(0.5, Enum.EasingStyle.Circular), {
				BackgroundTransparency = x.Name == e and 0.1 or 0.5
			}):Play()
		end
	end

	local n = tick()
	latestContainer = n

	for _, h in pairs(gui.container:GetChildren()) do
		if not h:IsA("Frame") and not h:IsA("ScrollingFrame") then continue end

		h.Visible = h.Name == e

		if h.Name ~= e then continue end

		task.spawn(function()
			canint.protect("loading")
			gui.loading.Visible = true

			if h.Name == "audios" then
				if firstAud then
					firstAud = false
					task.spawn(function()
						if workspace.data.game.broken.Value then
							local answer
							while answer ~= "I Understand" do
								answer = popup("Important", "All audios are currently declined due to a Roblox bug.", {"Ok", "I Understand"})
							end
						else
							popup("Important", "Some audios can't be played due to copyright.", {"Ok"})
						end
					end)
				end

				local topage = {}
				local page = 1

				local function makeToPage()
					local src = h.searching.left.search.Text
					topage = dataGetter:GetBrowserTab(src, filters.show, filters.sort, filters.creator, page)
				end
				makeToPage()

				local function renderPage(clearPage)
					local src = h.searching.left.search.Text

					if clearPage then
						for _, g in pairs(h.list:GetChildren()) do if g:GetAttribute("yes") then g:Destroy() end end
					end
					for _, a in pairs(topage) do
						if h.list:FindFirstChild(tostring(a.id)) then continue end
						local l, sond = script.audio:Clone(), newSound()
						l.Name = tostring(a.id)
						l, sond = loadSongUI(a, l, sond)
						l.LayoutOrder = a.index

						local respo = makeImageStuff(sond, l.controls.play, l.controls.play, "list_"..a.id, true)

						task.spawn(function()
							task.wait(0.5)
							if not l.Parent then return end
							local hasFinished = false
							local canLoad = false

							CNTP:PreloadAsync({sond}, function(id, status)
								canLoad = status == Enum.AssetFetchStatus.Success
								hasFinished = true
							end)
							repeat task.wait() until hasFinished

							if not canLoad then return respo() end

							repeat task.wait() until sond.IsLoaded

							if not l:FindFirstChild("controls") then return end
							l.controls.play.Activated:Connect(function()
								if not canint.check() or isfilt then return end
								local ps = not sond.IsPlaying

								if audplay ~= sond then
									if audplay then
										audplay:Stop()
										audtracker()
									end
									game.ReplicatedStorage.events.tracking.UpdateSettings:FireServer("history", a.id)
									audtracker(sond, l)
								end

								if ps then sond:Resume()
								else sond:Pause() end
							end)
						end)

						l.Parent = h.list
					end

					h.list.noaudios.Visible = #topage == 0
					h.list.UIListLayout.VerticalAlignment = #topage == 0 and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top
					if #topage == 0 then
						local textt = ""
						if filters.show == "creator" then textt = "Try a different creator."
						elseif filters.show == "favorites" then textt = "Try favoriting an audio first."
						elseif filters.show == "history" then textt = "Try listening to an audio first."
						elseif trim(src) ~= "" then textt = "Try a different search." end

						h.list.noaudios.Text = `No audios found! {textt}`
					end
				end
				renderPage(true)

				local otxt = ""
				local ofil = filters.check

				table.insert(jevs, RNs.RenderStepped:Connect(function()
					local txt = h.searching.left.search.Text
					task.spawn(function()
						if gui.loading.Visible then return end
						if txt ~= otxt or ofil ~= filters.check then
							page = 1
							canint.protect("loadingbrowser")
							gui.loading.Visible = true
							makeToPage()
							renderPage(true)
							canint.unprotect("loadingbrowser")
							gui.loading.Visible = false
						elseif h.list.CanvasPosition.Y >= h.list.AbsoluteCanvasSize.Y-h.list.AbsoluteSize.Y-15 and canint.check() and #topage ~= 0 and (#topage % 25 == 0) then
							canint.protect("loadingbrowser")
							gui.loading.Visible = true
							page += 1
							makeToPage()
							renderPage()
							canint.unprotect("loadingbrowser")
							gui.loading.Visible = false
						end
					end)

					otxt = txt
					ofil = filters.check
				end))
			elseif h.Name == "leaderboard" then
				local trophies = {"🥇","🥈","🥉","🎖"}

				local chosen = "audios"
				local topage = {}
				local page = 1
				local function maketoPage()
					topage = dataGetter:GetLeaderboardTab(chosen, page)
				end

				local function renderTab(clearPage)
					if clearPage then
						for _, g in pairs(h.list:GetChildren()) do if g:GetAttribute("yes") then g:Destroy() end end
					end

					for _, ldt in pairs(topage) do
						if h.list:FindFirstChild(tostring(ldt.user.id)) then continue end

						local J = ldt.index
						local l = script.ldplayer:Clone()
						l.LayoutOrder = J
						l.Name = tostring(ldt.user.id)
						l.icon.Image = `rbxthumb://type=AvatarHeadShot&id={ldt.user.id}&w=420&h=420`
						l.stats.info.Text = "#"..J

						local function renThing(user, log)
							return `{user.name}{user.verified and ` {unicode.verified}` or ""}{trophies[J] and ` {trophies[J]}` or ""}`
						end

						if chosen == "audios" then
							l.metadata.title.Text = renThing(ldt.user)
							l.metadata.user.Text = `Ranked as "{ldt.user.role}"`
							l.stats.stat.Text = `Uploaded {ldt.count} audio{ldt.count~=1 and "s" or ""}`

							local function ohyeah()
								if not canint.check() then return end
								selectContainer("audios")
								task.wait()
								filters.show = "creator"
								filters.creator = ldt.user.name
								gui.container.audios.searching.left.creator.value.Text = ldt.user.name
							end
							table.insert(jevs, l.icon.MouseButton2Click:Connect(ohyeah))
							table.insert(jevs, l.icon.TouchLongPress:Connect(ohyeah))
						elseif chosen == "donations" then
							l.metadata.title.Text = ldt.user.name and renThing(ldt.user) or "-"
							l.metadata.user.Visible = false
							l.stats.stat.Text = `Donated {unicode.robux}{ldt.count}`

							task.spawn(pcall, function()
								local user = game.ReplicatedStorage.events.GetPlayer:InvokeServer(ldt.user.id)
								if user then l.metadata.title.Text = renThing(user) end
							end)
						end

						l.Parent = h.list
					end
				end

				maketoPage()
				renderTab(true)
				for _, x in pairs(h.tabs:GetChildren()) do
					if not x:IsA("TextButton") then continue end
					table.insert(jevs, x.Activated:Connect(function()
						if not canint.check() then return end
						if chosen == x.Name then return end

						canint.protect("loadingleaderboard")
						gui.loading.Visible = true
						page = 1
						chosen = x.Name
						maketoPage()
						renderTab(true)
						gui.loading.Visible = false
						canint.unprotect("loadingleaderboard")
					end))
				end
				table.insert(jevs, RNs.RenderStepped:Connect(function()
					if gui.loading.Visible then return end

					if h.list.CanvasPosition.Y >= h.list.AbsoluteCanvasSize.Y-h.list.AbsoluteSize.Y-15 and canint.check() and #topage ~= 0 and (#topage % 50 == 0) then
						canint.protect("loadingleaderboard")
						gui.loading.Visible = true
						page += 1
						maketoPage()
						renderTab()
						gui.loading.Visible = false
						canint.unprotect("loadingleaderboard")
					end
				end))
			elseif h.Name == "donate" then
				local data = dataGetter:GetDonateTab()

				for J, d in pairs(data.clothing) do
					if d.priceStatus == "Offsale" or not d.price then continue end
					local l = script.donate:Clone()
					l.Name = tostring(d.id)
					l.LayoutOrder = J
					l.image.Image = `rbxthumb://type=Asset&id={d.id}&w=420&h=420`
					l.name.Text = d.name
					l.price.Text = `{unicode.robux}{d.price or "-"}`
					l.image.Activated:Connect(function()
						if not canint.check() then return end
						MKPs:PromptPurchase(plr, d.id, false, Enum.CurrencyType.Tix)
					end)

					l.Parent = h.items
					if J % 20 == 0 then task.wait() end
				end

				h.desc.Text = `Help fund OCM with donations! (20+ robux = Donator rank) Group Funds: {unicode.robux}{data.funds}`
			elseif h.Name == "badges" then
				local owned, all = 0, 0
				for id in pairs(ABadges) do
					local jj = cacheBadge(id)
					all += 1
					if jj.owns then owned += 1 end
				end
				h.container.badges.label.Text = `🎖 Collected {owned}/{all} badges ({math.floor((owned/all)*100)}%)`

				local i = 0
				for id, d in pairs(ABadges) do
					i+=1
					local badge = cacheBadge(id)

					local l = script.badge:Clone()
					local icon = "rbxassetid://"..badge.displayIconImageId
					l.Image = icon
					l.ImageColor3 = badge.owns and Color3.new(1, 1, 1) or Color3.new(0.35, 0.35, 0.35)
					l.Name = tostring(id)
					l.LayoutOrder = i
					l.check.Visible = badge.owns
					l.Activated:Connect(function()
						h.container.info.image.check.Visible = badge.owns
						h.container.info.image.Image = icon
						h.container.info.image.ImageColor3 = badge.owns and Color3.new(1, 1, 1) or Color3.new(0.35, 0.35, 0.35)

						local soiz = h.container.info.AbsoluteSize.X
						local saz = h.container.info.AbsoluteSize.Y
						local t1s = saz * 0.05
						local t2 = `({badge.statistics.awardedCount} {badge.statistics.awardedCount == 1 and "person has" or "people have"} achieved this badge)`
						local t2s = saz * 0.038
						local t3s = saz * 0.08

						local t1R = TXTs:GetTextSize(d, t1s, Enum.Font.Highway, Vector2.new(soiz, 99999))
						local t2R = TXTs:GetTextSize(t2, t2s, Enum.Font.Highway, Vector2.new(soiz, 99999))
						local t3R = TXTs:GetTextSize(badge.name, t3s, Enum.Font.Highway, Vector2.new(soiz, 99999))

						local appear = badgeAppearance[id]
						h.container.info.rarity.Visible = not not appear
						if appear then
							h.container.info.rarity.Text = appear[1]
							h.container.info.rarity.TextColor3 = precolors.rarities[appear[1]]
						end

						h.container.info.title.Text = badge.name
						h.container.info.title.Size = UDim2.new(1, 0, math.round(t3R.Y/t3s)*0.08, 0)

						h.container.info.desc.Text = d
						h.container.info.desc.Size = UDim2.new(1, 0, math.round(t1R.Y/t1s)*0.05, 0)

						h.container.info.people.Text = t2
						h.container.info.people.Size = UDim2.new(1, 0, math.round(t2R.Y/t2s)*0.038, 0)

						h.container.info.ws.Visible = true
						h.container.info.image.Visible = true
						h.container.info.title.Visible = true
						h.container.info.desc.Visible = true
						h.container.info.people.Visible = true
					end)

					l.Parent = h.container.badges.badges
					if i % 11 == 0 then task.wait() end
				end
			elseif h.Name == "chattags" then
				for _, x in pairs(h.namecolor:GetChildren()) do if x:IsA("Frame") and not x:GetAttribute("no") and x.Visible then x:Destroy() end end
				for _, x in pairs(h.namecolorgradient:GetChildren()) do if x:IsA("Frame") and x.Visible then x:Destroy() end end
				for _, x in pairs(h.tags:GetChildren()) do if x:IsA("TextButton") and x.Visible then x:Destroy() end end

				local Eblend, Egradblend

				local reps = {}
				for x, cl in pairs(precolors.colors) do
					local i = table.find(precolors.colorsOrder, x)
					if not i then continue end

					local rep = h.namecolor.preset:Clone()
					rep.Name = x
					rep.Visible = true
					rep.BackgroundColor3 = cl
					rep.LayoutOrder = i
					rep.btn.Activated:Connect(function()
						if not canint.check() then return end

						game.ReplicatedStorage.events.tracking.UpdateSettings:FireServer("pref.namecolor", x)
					end)
					hoverDesc(rep.btn, x)
					rep.Parent = h.namecolor

					if x == "auto blend" then Eblend = rep end

					reps[rep] = x
				end

				for x, grd in pairs(precolors.gradients) do
					local i = table.find(precolors.gradientsOrder, x)
					if not i then continue end

					local rep = h.namecolorgradient.presetgrad:Clone()
					rep.Name = x
					rep.Visible = true
					rep.gradient.Color = grd
					rep.LayoutOrder = i
					rep.btn.Activated:Connect(function()
						if not plr.gamepasses:GetAttribute("gradients") or not canint.check() then return end

						game.ReplicatedStorage.events.tracking.UpdateSettings:FireServer("pref.namecolor", x)
					end)
					hoverDesc(rep.btn, x)
					rep.Parent = h.namecolorgradient

					if x == "gradient auto blend" then Egradblend = rep end

					reps[rep] = x
				end

				for i, X in pairs(chatTools:GetLocalTags()) do
					local tag = h.tags.preset:Clone()
					tag.Name = X.text
					tag.LayoutOrder = i
					tag.Text = X.text
					tag.Visible = true
					tag.Activated:Connect(function()
						if not canint.check() then return end

						game.ReplicatedStorage.events.tracking.UpdateSettings:FireServer("pref.toggletag", X.text, not tag:GetAttribute("hidden"))
					end)
					tag.Parent = h.tags
				end

				jevs[#jevs+1] = h.namecolor.buygradient.btn.Activated:Connect(function()
					if plr.gamepasses:GetAttribute("gradients") then return end

					MKPs:PromptGamePassPurchase(plr, gamepasses.lookup.gradients)
				end)

				local oldstuff = {}
				jevs[#jevs+1] = RNs.RenderStepped:Connect(function()
					h.preview.const.MaxTextSize = h.preview.AbsoluteSize.Y/3.51619

					local rawTags = chatTools:GetLocalTags()
					local tags = {}
					local tagMap = {}

					local chatCol = plr:GetAttribute("chChatColor") or Color3.new(1, 1, 1)
					local nameCol = plr:GetAttribute("chNameColor") or chatTools:GetChatColor(plr.Name)
					local namm = chatTools:GetNameDisplay(plr.DisplayName)

					for _, t in pairs(rawTags) do
						tagMap[t.text] = t
						if t.hidden then continue end

						table.insert(tags, chatTools:ChooseRichify(chatTools:GetTagDisplay(t.text), chatTools:GetTagColor(t)))
					end

					h.preview.Text =
						`{table.concat(tags, " ")}{tags[1] and " " or ""}{chatTools:ChooseRichify(namm, nameCol)} {chatTools:Richify("wow this looks so cool", chatCol)}`

					local ownsGradient = plr.gamepasses:GetAttribute("gradients")
					h.namecolor.buygradient.Visible = not ownsGradient
					h.namecolorgradient.Visible = ownsGradient

					if Eblend then Eblend.BackgroundColor3 = chatTools:MakeBlend(rawTags, chatCol) end
					if Egradblend then Egradblend.gradient.Color = chatTools:MakeBlendGradient(rawTags, chatCol) end

					local hasTag = #h.tags:GetChildren() > 2
					h.tags.Visible = hasTag
					h.notags.Visible = not hasTag

					for _, x in pairs(h.tags:GetChildren()) do
						if not x:IsA("TextButton") then continue end
						local map = tagMap[x.Name]
						if not map then x.Visible = false; continue end

						x:SetAttribute("hidden", map.hidden)
						x.BackgroundColor3 = Color3.fromHSV(
							0,
							map.hidden and 0.5 or 0,
							0.2235
						)
					end

					local tabby = 1 / h.tags.grid.AbsoluteCellCount.Y
					local tabbo = h.tags.grid.AbsoluteCellCount.Y * 0.06
					h.tags.Size = UDim2.new(1, 0, tabbo, 0)
					h.tags.grid.CellSize = UDim2.new(0.20, -5, tabby, -5)

					local change = false
					local temm = chatTools:ConvertColor(nameCol)
					for A, B in pairs(reps) do
						local bool = myData.preferences.nameColor == B

						if oldstuff[A] ~= bool then change = true end
						oldstuff[A] = bool
					end

					if change then
						for A in pairs(reps) do
							TWNs:Create(A.stroke, TweenInfo.new(0.369, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
								Thickness = oldstuff[A] and 4 or 0
							}):Play()
						end
					end
				end)
			end

			canint.unprotect("loading")
			gui.loading.Visible = false
		end)
	end
end

for _, g in pairs(gui.navbar:GetChildren()) do
	if not g:IsA("Frame") then continue end

	g.text.Activated:Connect(function()
		if not canint.check() then return end

		selectContainer(g.Name)
	end)
end

gui.container.about.f1.update.MouseButton1Click:Connect(function()
	if not canint.check() then return end
	toClipboard("https://twitter.com/ocmusic_real/status/1589230630222823424")
end)

selectContainer("about")
firstTab = false

game.ReplicatedStorage.events.tabs.donate.Receipt.OnClientEvent:Connect(function(dt)
	popup(
		"Donation",
		`Thank you for purchasing <b>{dt.Name}</b> for <b>{unicode.robux}{dt.PriceInRobux}</b>!\n\nIf you have donated over {unicode.robux}20, click "Sync Rank" in settings to get your rank.`,
		{"Ok"}
	)
end)
game.ReplicatedStorage.events.Message.OnClientEvent:Connect(function(a, b, c, d)
	local respn = popup(a, b, c)
	if d and respn then
		game.ReplicatedStorage.events.Message:FireServer(d, respn)
	end
end)

local function sendSystemMessage(data: { Color: Color3?, TextSize: number?, Text: string })
	local chat: TextChannel = game.TextChatService.TextChannels.RBXGeneral

	local metadata = {}
	if data.Color then metadata[#metadata+1] = {"color", "#"..data.Color:ToHex()} end
	if data.TextSize then metadata[#metadata+1] = {"size", tostring(data.TextSize)} end

	for i, x: {string} in pairs(metadata) do
		metadata[i] = table.concat(x, ";")
	end

	chat:DisplaySystemMessage(data.Text, table.concat(metadata, ";;"))
end

local joinLeaveN = false
game.Players.PlayerAdded:Connect(function(p)
	if not joinLeaveN then return end
	sendSystemMessage({
		Text = `<i>{p.Name} has joined</i>`,
		TextSize = 16
	})
end)

game.Players.PlayerRemoving:Connect(function(p)
	if p == plr and not RNs:IsStudio() and doOsu then
		local dsound = script.sfx.osu.s1
		for _, s in pairs(workspace:GetDescendants()) do
			if s:IsA("Sound") and s ~= dsound then s:Destroy() end
		end
		dsound:Play()
	end

	if not joinLeaveN then return end
	sendSystemMessage({
		Text = `<i>{p.Name} has left</i>`,
		TextSize = 16
	})
end)

game.ReplicatedStorage.events.tracking.RunQBadge.OnClientEvent:Connect(function()
	canint.protect("run???")
	blockAll = true
	gui.secretBadge.Visible = true

	local letters = ("死;殺;人;者;永;遠;の;苦;し;み"):split(";")
	local silly = gui.secretBadge["me when im silly"]
	local gaslight = gui.secretBadge["me when i gaslight"]

	silly.Visible = false

	local lettit = true
	task.spawn(function()
		task.wait(Random.new():NextNumber(1, 2))
		while lettit do
			local lad = letters[math.random(1, #letters)]
			local let = script.japanese:Clone()
			let.Name = lad
			let.Text = lad
			let.Rotation = math.random(-15, 15)
			let.TextTransparency = 0.8
			let.Position = UDim2.new(
				Random.new():NextNumber(0, 1),
				0,
				Random.new():NextNumber(0, 1),
				0
			)

			let.Parent = gui.secretBadge
			local twiin = TWNs:Create(let, TweenInfo.new(Random.new():NextNumber(0.4, 2)), {
				TextTransparency = 1
			})
			twiin:Play()
			twiin.Completed:Connect(function()
				let:Destroy()
			end)

			task.wait(Random.new():NextNumber(0.1, 0.4))
		end
	end)

	game.SoundService.listAudio.Volume = 0
	script.sfx["???"].silly:Play()

	silly.Visible = true
	silly.ImageTransparency = 1
	local twan = TWNs:Create(silly, TweenInfo.new(13, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
		ImageTransparency = 0.8
	})
	local twin = TWNs:Create(script.sfx["???"].silly, TweenInfo.new(12, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Volume = 8
	})
	twin:Play()
	twan:Play()
	task.wait(10)
	twan:Cancel()
	twin:Cancel()
	lettit = false

	canint.unprotect("run???")
	blockAll = false
	script.sfx["???"].silly:Stop()
	script.sfx["???"].sting:Play()

	gui.secretBadge.BackgroundTransparency = 1
	gaslight.Visible = true
	gaslight.TextTransparency = 0.3
	silly.ImageTransparency = 0.5
	silly.Visible = true
	TWNs:Create(game.SoundService.listAudio, TweenInfo.new(1, Enum.EasingStyle.Sine), {
		Volume = 1
	})
	TWNs:Create(gaslight, TweenInfo.new(2), {
		TextTransparency = 1
	}):Play()
	local twiin = TWNs:Create(silly, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		ImageTransparency = 1,
		Size = UDim2.new(0.45, 0, 0.45, 0)
	})
	twiin:Play()
	twiin.Completed:Connect(function()
		gui.secretBadge.Visible = false
	end)
end)

teleportingAppear = function(text)
	gui.teleporting.text.Text = text

	gui.teleporting.icon.Size = UDim2.new()

	gui.teleporting.BackgroundTransparency = 1
	gui.teleporting.Visible = true

	gui.teleporting.BackgroundTransparency = 1
	TWNs:Create(gui.teleporting, TweenInfo.new(0.5), {
		BackgroundTransparency = 0.5
	}):Play()
	TWNs:Create(gui.teleporting.icon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.18, 0, 0.18, 0)
	}):Play()
end
teleportingDisappear = function(deficon)
	TWNs:Create(gui.teleporting, TweenInfo.new(0.5), {
		BackgroundTransparency = 1
	}):Play()
	TWNs:Create(gui.teleporting.icon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Size = UDim2.new()
	}):Play()

	task.delay(0.3, function()
		gui.teleporting.Visible = false
	end)
end

game.ReplicatedStorage.events.chat.SMessage.OnClientEvent:Connect(function(data)
	sendSystemMessage(data)
end)

game.ReplicatedStorage.events.chat.Tip.OnClientEvent:Connect(function(tip)
	sendSystemMessage({
		Text = `{chatTools:GetNameDisplay("Tip")} {tip}`,
		Color = Color3.new(0.482353, 0.517647, 1),
		TextSize = 16
	})
end)

local badgeN = false
game.ReplicatedStorage.events.chat.GotBadge.OnClientEvent:Connect(function(badgeId, username)
	if not badgeN then return end
	local badge = cacheBadge(badgeId) or tempBadge

	sendSystemMessage({
		Text = `{username} got the "{badge.name}" badge!`,
		Color = Color3.new(0.745098, 1, 0.909804),
		TextSize = 16
	})
end)
game.ReplicatedStorage.events.tracking.GotBadge.OnClientEvent:Connect(function(badgeId)
	badgeCache[badgeId] = nil
	local badge = cacheBadge(badgeId) or tempBadge

	if badgeId == 2141673520 then
		script.sfx.badge.tada:Play()
		script.sfx.badge.yippee:Play()
	end

	notifs("badge", badge.name)
end)

game.ReplicatedStorage.events.Teleporting.OnClientEvent:Connect(function(msg)
	teleportingAppear(msg)
end)

plr.OnTeleport:Connect(function()
	doOsu = false

	local tabName, tabPos, tabQuery
	for _, j in pairs(gui.container:GetChildren()) do
		if (j:IsA("Frame") or j:IsA("ScrollingFrame")) and j.Visible then
			tabName = j.Name

			if j.Name == "audios" then tabQuery = j.searching.left.search.Text end
		end
	end

	local songId, songTime, songLoop, songStatus

	songLoop = auLooped
	if audplay then
		songId = audplay:GetAttribute("id")
		songTime = audplay.TimePosition
		songStatus = audplay.IsPlaying
	end

	local speedVal = tonumber(gui.bgplayer.other.tempo.value.Text) or 1
	speedVal = math.clamp(speedVal, 0, 10)
	local spawnJam = gui.jam.Visible

	TPs:SetTeleportSetting("audioData", {
		tabName = tabName,
		tabQuery = tabQuery,
		songId = songId,
		songTime = songTime,
		songLoop = songLoop,
		songStatus = songStatus,
		speedVal = speedVal,
		spawnJam = spawnJam
	})
	TPs:SetTeleportSetting("returnToBeta", workspace.data.server.beta.Value)
end)

task.spawn(function()
	while task.wait(0.5) do
		local alt = UIs:IsKeyDown(Enum.KeyCode.LeftAlt)
		if myData and myData.track.alt ~= alt then game.ReplicatedStorage.events.tracking.UpdateSettings:FireServer("alt", alt); end
	end
end)

local seekt = 5
local mappings = {
	[Enum.KeyCode.Zero] = 0,
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
	[Enum.KeyCode.KeypadZero] = 0,
	[Enum.KeyCode.KeypadOne] = 1,
	[Enum.KeyCode.KeypadTwo] = 2,
	[Enum.KeyCode.KeypadThree] = 3,
	[Enum.KeyCode.KeypadFour] = 4,
	[Enum.KeyCode.KeypadFive] = 5,
	[Enum.KeyCode.KeypadSix] = 6,
	[Enum.KeyCode.KeypadSeven] = 7,
	[Enum.KeyCode.KeypadEight] = 8,
	[Enum.KeyCode.KeypadNine] = 9,
}

UIs.InputBegan:Connect(function(k)
	if UIs:GetFocusedTextBox() or not canint.check() then return end

	local isCtrl = k:IsModifierKeyDown(Enum.ModifierKey.Ctrl)
	local isShift = k:IsModifierKeyDown(Enum.ModifierKey.Shift)

	if not isShift and isCtrl then
		if k.KeyCode == Enum.KeyCode.L then
			selectContainer("audios")
		elseif k.KeyCode == Enum.KeyCode.D then
			selectContainer("donate")
		elseif k.KeyCode == Enum.KeyCode.A then
			selectContainer("about")
		elseif k.KeyCode == Enum.KeyCode.B then
			selectContainer("badges")
		elseif k.KeyCode == Enum.KeyCode.R then
			selectContainer("leaderboard")
		elseif k.KeyCode == Enum.KeyCode.S then
			selectContainer("settings")
		end
	end

	if isShift and not isCtrl and audplay then
		if k.KeyCode == Enum.KeyCode.Return then
			if canint.isprotect("jam") then
				canint.unprotect("jam")
				jamify(false)
			else
				canint.protect("jam")
				jamify(true)
			end
		elseif k.KeyCode == Enum.KeyCode.L then
			auLooped = not auLooped
		elseif k.KeyCode == Enum.KeyCode.Up or k.KeyCode == Enum.KeyCode.Down then
			local curr = tonumber(gui.bgplayer.other.tempo.value.Text) or 1
			curr *= 10
			curr += k.KeyCode.Name == "Up" and 1 or -1
			curr = math.floor(curr)/10

			gui.bgplayer.other.tempo.value.Text = tostring(math.clamp(curr, 0, 10))
		end
	end

	if not isShift and not isCtrl and audplay then
		if (k.KeyCode == Enum.KeyCode.Left or k.KeyCode == Enum.KeyCode.Right) and seekt then
			local npos = k.KeyCode.Name == "Left" and audplay.TimePosition-seekt or audplay.TimePosition+seekt
			audplay.TimePosition = math.clamp(npos, 0, audplay.TimePosition)
		elseif k.KeyCode == Enum.KeyCode.Space then
			if audplay.IsPlaying then audplay:Pause()
			else audplay:Resume() end
		elseif mappings[k.KeyCode] then
			local jt = mappings[k.KeyCode]/10
			audplay.TimePosition = audplay.TimeLength*jt
		end
	end
end)

local function updateSettings(data)
	local settsM = require(game.ReplicatedStorage.modules.settings)

	local function getSetting(val)
		local sm = settsM[val]

		if data[val] == nil then
			if typeof(sm) == "boolean" then
				data[val] = sm
			else data[val] = sm[1] end
		end
		if typeof(sm) == "table" then
			if not table.find(sm, data[val]) then
				data[val] = sm[1]
			end
		end

		return data[val]
	end
	local function setSetting(el, val, handler, tag)
		local function set()
			local v = getSetting(val)

			if typeof(v) == "boolean" then
				el.Option.Toggle.Image = v and allicons.check or allicons.close
			else
				el.Option.Dropdown.Text = v
			end
		end

		if not handler then return end
		if el.Option:FindFirstChild("Toggle") then
			el.Option.Toggle.Activated:Connect(function()
				if not canint.check() and not canint.isprotect(tag) then return end

				local new = not getSetting(val)
				data[val] = new
				game.ReplicatedStorage.events.settings.Update:FireServer(val, new)

				set()
				task.spawn(handler, new)
			end)
		elseif el.Option:FindFirstChild("Dropdown") then
			dropdownElement(el.Option.Dropdown, settsM[val], function(response)
				data[val] = response
				game.ReplicatedStorage.events.settings.Update:FireServer(val, response)

				set()
				handler(response)
			end, 5, false, tag)
		end

		set()
		task.spawn(handler, getSetting(val))
	end

	local st = gui.container.settings
	setSetting(st.interface.content.Badge, "badge", function(val)
		badgeN = val
	end)
	setSetting(st.interface.content.Joins, "joins", function(val)
		joinLeaveN = val
	end)
	setSetting(st.interface.content.NavbarPos, "navbar", function(val)
		local containerYOffset = gui.container.Position.Y.Offset

		if val == "Left" or val == "Right" then
			gui.container.Position = val == "Left" and UDim2.new(0.1, 0, 0, containerYOffset) or UDim2.new(0, 0, 0, containerYOffset)
			gui.container.Size = UDim2.new(0.9, 0, 1, 0)
			gui.navbar.Position = val == "Left" and UDim2.new() or UDim2.new(0.9, 0, 0, 0)
			gui.navbar.Size = UDim2.new(0.1, 0, 1, 0)
			gui.navbar.grid.CellSize = UDim2.new(0.9, 0, 0.12, -10)
			gui.navbar.grid.FillDirection = Enum.FillDirection.Horizontal
			gui.bgplayer.Position = UDim2.new(
				val == "Left" and 0.1 or 0,
				0,
				gui.bgplayer.Position.Y.Scale,
				0
			)
			gui.bgplayer.Size = UDim2.new(0.9, 0, 0.1, 0)

			for _, x in pairs(gui.navbar:GetChildren()) do
				if x:FindFirstChild("text") then x.text.Size = UDim2.new(1, 0, 0.4, 0) end
			end
			for _, x in pairs(gui.container:GetDescendants()) do
				if x:IsA("ScrollingFrame") then
					x.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition[val == "Left" and "Right" or "Left"]
				end
			end
		elseif val == "Down" or val == "Up" then
			gui.container.Position = val == "Down" and UDim2.new(0, 0, 0, containerYOffset) or UDim2.new(0, 0, 0.1, containerYOffset)
			gui.container.Size = UDim2.new(1, 0, 0.9, 0)
			gui.navbar.Position = val == "Down" and UDim2.new(0, 0, 0.9, 0) or UDim2.new(0, 0, 0, 0)
			gui.navbar.Size = UDim2.new(1, 0, 0.1, 0)
			gui.navbar.grid.CellSize = UDim2.new(0.12, -10, 0.9, 0)
			gui.navbar.grid.FillDirection = Enum.FillDirection.Vertical
			gui.bgplayer.Position = UDim2.new(
				0,
				0,
				gui.bgplayer.Position.Y.Scale,
				0
			)
			gui.bgplayer.Size = UDim2.new(1, 0, 0.1, 0)

			for _, x in pairs(gui.navbar:GetChildren()) do
				if x:FindFirstChild("text") then x.text.Size = UDim2.new(1, 0, 0.5, 0) end
			end
			for _, x in pairs(gui.container:GetDescendants()) do
				if x:IsA("ScrollingFrame") then
					x.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
				end
			end
		end
	end)

	local tcache = {}
	setSetting(st.interface.content.Theme, "theme", function(val)
		local td = gui:GetDescendants()
		for _, x in pairs(script:GetDescendants()) do table.insert(td, x) end
		for _, x in pairs(game.ReplicatedStorage.modules:GetDescendants()) do table.insert(td, x) end

		local n = tick()

		for i, x in pairs(td) do
			local function caching(p)
				if not tcache[x] then tcache[x] = {} end
				pcall(function()
					if not tcache[x][p] then tcache[x][p] = x[p] end
				end)
			end
			local function uncaching(p)
				if tcache[x] and tcache[x][p] then
					pcall(function()
						x[p] = tcache[x][p]
					end)
				end
			end
			local function setcaching(p, v)
				pcall(function()
					TWNs:Create(x, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						[p] = v
					}):Play()
				end)
			end
			local function uncacheall()
				if tcache[x] then
					for p, v in pairs(tcache[x]) do
						setcaching(p, v)
					end
				end
			end
			local function getcaching(p)
				return tcache[x] and tcache[x][p] or nil
			end
			local function valinvcache(p, i, mlt)
				if tcache[x] and tcache[x][p] then
					pcall(function()
						local H, S, V = tcache[x][p]:ToHSV()
						setcaching(p, Color3.fromHSV(H, S, math.max(i-(V*mlt), 0)))
					end)
				end
			end
			local function hueshift(p, t, h, s, v)
				if tcache[x] and tcache[x][p] then
					pcall(function()
						local H, S, V = tcache[x][p]:ToHSV()
						if t == "set" then
							if h then H = h end
							if s then S = s end
							if v then V = v end
						else
							if h then H += h end
							if s then S += s end
							if v then V += v end
						end

						setcaching(p, Color3.fromHSV(H, S, V))
					end)
				end
			end

			local bgc3C, bgc3 = pcall(function()
				return x.BackgroundColor3
			end)
			if not bgc3C then continue end
			caching("BackgroundColor3")
			caching("BackgroundTransparency")
			caching("TextColor3")
			caching("TextTransparency")
			caching("ImageColor3")
			caching("ImageTransparency")

			iconGray = Color3.new(0.760784, 0.760784, 0.760784)
			uncacheall()

			local bl = {
				gui.container.badges.container.info.image,
				script.badge,
				script.indicator,
				script.ldplayer.icon,
				script.donate.image,
				script.linee,
				gui.loading,
				gui.teleporting.icon.icon,
				gui.teleporting.text,
				gui.container.about.f2.figure,
				gui.bgplayer.other.custom,
				gui.desc,
				gui.portrait,
				gui.jam.all.icon.main,
				gui.container.chattags.namecolor.preset,
				gui.container.chattags.namecolorgradient.presetgrad,
				--gui.tutorial.backdrop,
				--gui.tutorial.caption,
				--gui.tutorial.caption
			}

			local isdiscolored = table.find({Color3.new(1, 1, 1), Color3.new(0, 0, 0)}, getcaching("BackgroundColor3"))
			local donot = not not table.find(bl, x)
			if isdiscolored then
				if getcaching("BackgroundTransparency") >= 0.2 then
					donot = true
				end
			end
			local donot2 = isdiscolored or getcaching("BackgroundTransparency") == 1
			local donot3 = not not table.find(bl, x) or getcaching("ImageTransparency") == 1

			invr = false
			if val == "Light" or val == "Apple Store" then
				invr = true
				iconGray = Color3.new()
				local app = val == "Apple Store"

				if not donot then valinvcache("BackgroundColor3", 1, app and 0.2 or 1.4) end
				if not donot2 then
					setcaching("BackgroundTransparency", getcaching("BackgroundTransparency")-(app and 0.4 or 0.2))
				end

				if getcaching("TextTransparency") and not donot2 then
					setcaching("TextTransparency", getcaching("TextTransparency")-(app and 0.4 or 0.2))
				end
				if not table.find(bl, x) then
					valinvcache("TextColor3", 0, 0)
				end

				if getcaching("ImageTransparency") and not donot2 then
					setcaching("ImageTransparency", getcaching("ImageTransparency")-(app and 0.4 or 0.2))
				end
				if not donot3 then
					valinvcache("ImageColor3", 0, 0)
				end
			elseif val == "Void" then
				iconGray = Color3.new(1, 1, 1)

				if not donot then valinvcache("BackgroundColor3", 0.1, 0.5) end
				if not donot2 then
					setcaching("BackgroundTransparency", getcaching("BackgroundTransparency")-0.4)
				end

				if getcaching("TextTransparency") and not donot2 then
					setcaching("TextTransparency", getcaching("TextTransparency")-0.4)
				end
				if not table.find(bl, x) then
					valinvcache("TextColor3", 1, 0)
				end

				if getcaching("ImageTransparency") and not donot2 then
					setcaching("ImageTransparency", getcaching("ImageTransparency")-0.4)
				end
				if not donot3 then
					valinvcache("ImageColor3", 1, 0)
				end
			end

			-- hue shifters
			local hs = {
				Ocean = {"set", 0.586278, 1}
			}
			if hs[val] then
				local d = hs[val]
				if not donot then
					hueshift("BackgroundColor3", unpack(d))
				end
			end

			if i % 1000 == 0 then task.wait() end
		end
	end, "tutorial_settings.Theme")
	setSetting(st.interface.content.Visualizer, "visualizer", function(val)
		gui.bgplayer.other.custom.Visible = false
		for _, j in pairs(gui.visualizer.bars:GetChildren()) do if j:IsA("Frame") then j:Destroy() end end

		if val == "Bars" then
			for i = 1, 40 do
				local b = script.bar:Clone()
				b.Name = i
				b.LayoutOrder = i
				b.Parent = gui.visualizer.bars
			end
		elseif val == "Dwayne" then
			gui.bgplayer.other.custom.stages.Value = 8
			gui.bgplayer.other.custom.grid.Value = 3
			gui.bgplayer.other.custom.Image = "rbxassetid://10815479060"
			gui.bgplayer.other.custom.ImageRectSize = Vector2.new(220, 220)
			gui.bgplayer.other.custom.Visible = true
		elseif val == "Wawa Cat" then
			gui.bgplayer.other.custom.stages.Value = 24
			gui.bgplayer.other.custom.grid.Value = 5
			gui.bgplayer.other.custom.Image = "rbxassetid://10815529069"
			gui.bgplayer.other.custom.ImageRectSize = Vector2.new(204, 204)
			gui.bgplayer.other.custom.Visible = true
		elseif val == "Sims Cat Breakdancing (old)" then
			gui.bgplayer.other.custom.stages.Value = 16
			gui.bgplayer.other.custom.grid.Value = 4
			gui.bgplayer.other.custom.Image = "rbxassetid://11086229037"
			gui.bgplayer.other.custom.ImageRectSize = Vector2.new(120, 120)
			gui.bgplayer.other.custom.Visible = true
		elseif val == "Sims Cat Breakdancing" then
			gui.bgplayer.other.custom.stages.Value = 31
			gui.bgplayer.other.custom.grid.Value = 6
			gui.bgplayer.other.custom.Image = "rbxassetid://11088098192"
			gui.bgplayer.other.custom.ImageRectSize = Vector2.new(121, 121)
			gui.bgplayer.other.custom.Visible = true
		elseif val == "Spinning Rat" then
			gui.bgplayer.other.custom.stages.Value = 25
			gui.bgplayer.other.custom.grid.Value = 5
			gui.bgplayer.other.custom.Image = "rbxassetid://11301372239"
			gui.bgplayer.other.custom.ImageRectSize = Vector2.new(204.8, 204.8)
			gui.bgplayer.other.custom.Visible = true
		end
	end)
	setSetting(st.interface.content.Waveform, "waveform", function(val)
		jamwaveform = val
	end)

	st.functionality.content.ChatTags.Option.Click.Activated:Connect(function()
		if not canint.check() then return end
		selectContainer("chattags")
	end)

	setSetting(st.functionality.content.Debug, "debug", function(val)
		gui.bgplayer.other.status.Visible = val
	end)
	setSetting(st.functionality.content.OldChatLook, "chatbrackets", function(val)
		workspace.data.server.cbrackets.Value = val
	end)
	setSetting(st.functionality.content.Seek, "seeking", function(val)
		if val == "Disabled" then seekt = false
		elseif val == "1s" then seekt = 1
		elseif val == "5s" then seekt = 5
		elseif val == "10s" then seekt = 10 end
	end)
	setSetting(st.functionality.content.Speed, "speed", function(val)
		audAffect.pitch = not not val:find("Pitch")
		audAffect.tempo = not not val:find("Tempo")
	end)

	-- Buttons
	local disrj = workspace.data.server.vip.Value or RNs:IsStudio()
	if disrj then
		st.underground.content.Rejoin.Metadata.title.TextTransparency += 0.3
		st.underground.content.Rejoin.Metadata.desc.TextTransparency += 0.3
		st.underground.content.Rejoin.Option.Click.TextTransparency += 0.3
		st.underground.content.Rejoin.Option.Click.BackgroundTransparency += 0.3
		st.underground.content.Rejoin.Option.Click.AutoButtonColor = false
	end

	st.underground.content.Rejoin.Option.Click.Activated:Connect(function()
		if not canint.check() then return end
		if disrj then return end

		canint.protect("rejoin")
		game.ReplicatedStorage.events.settings.Rejoin:FireServer()
		teleportingAppear("Rejoining...")
	end)

	st.underground.content.Sync.Option.Click.Activated:Connect(function()
		if not canint.check() then return end
		canint.protect("syncing")
		teleportingAppear("Syncing rank...")

		local scs, msg = game.ReplicatedStorage.events.tabs.settings.SyncRank:InvokeServer()
		canint.unprotect("syncing")
		teleportingDisappear()

		if not scs then popup("Error", msg, {"Ok"})
		else popup("Success", msg, {"Ok"}) end
	end)
	st.underground.content.Suggest.Option.Click.Activated:Connect(function()
		if not canint.check() then return end

		popup("disabled", "Suggestions have been disabled due to the influx of unwanted song suggestions, poor feedback and more. If you would like to help improve Obby Creator Music, join the communications server!", {"Ok"})
	end)

	st.underground.content.Reset.Option.Click.Activated:Connect(function()
		if not canint.check() then return end

		local rsp = popup("are you sure?", [[Restting ALL of your data will get rid of:

·  Your favorites
·  Your tracking data (audio history and ToS agreement)
·  Your settings]], {"Cancel", "Delete"})
		if rsp == "Cancel" then canint.unprotect("modalsubmit") return end

		canint.protect("datareset")
		teleportingAppear("Resetting data...")

		game.ReplicatedStorage.events.settings.Reset:InvokeServer()
	end)

	local policies = PLCs:GetPolicyInfoForPlayerAsync(plr)
	local links = policies.AllowedExternalLinkReferences or {}
	st.underground.content.Discord.Option.Click.Activated:Connect(function()
		if not canint.check() then return end

		local p = not not table.find(links, "Discord")
		if not p then
			local rsp = popup("are you sure?", [[Your account is not allowed to view external links (specifically Discord).

Do you still want to view the invite?]], {"Cancel", "View"})
			if rsp == "Cancel" then return end
		end

		toClipboard("https://discord.gg/K4gFUPTA7B")
	end)
end

task.spawn(function()
	local data = game.ReplicatedStorage.events.tracking.RequestData:InvokeServer()
	modUpdated(data)
	updateSettings(data.settings)
	local list = game.ReplicatedStorage.events.social.RequestList:InvokeServer()
	updateSocialList("global", list)
end)

gui.zloading.Visible = true
if not plr:GetAttribute("loaded") then
	local llstat = plr:WaitForChild("llstat")

	local loadingAt = 0
	local loadEv, lastStat
	loadEv = RNs.RenderStepped:Connect(function()
		if lastStat ~= llstat.Value then loadingAt = tick() end
		lastStat = llstat.Value

		local diff = math.floor((tick()-loadingAt)*2)
		gui.zloading.text.Text = llstat.Value .. ("."):rep(diff)
	end)
	canint.protect("loadingA")

	repeat task.wait() until not llstat.Parent
	loadEv:Disconnect()
	canint.unprotect("loadingA")
end

task.spawn(function()
	gui.zloading.text.Text = "loaded!"
	task.wait(0.7)
	local info = TweenInfo.new(0.5)

	local completed, fcompleted = 0, 0
	local trk, trk2 = TWNs:Create(gui.zloading, info, {
		BackgroundTransparency = 1
	})
	trk:Play()
	trk.Completed:Connect(function()
		completed += 1
	end)
	fcompleted += 1

	for _, x in pairs(gui.zloading:GetChildren()) do
		if not x:IsA("ImageLabel") then continue end

		local twn
		twn = TWNs:Create(x, info, {
			ImageTransparency = 1
		})
		twn:Play()
		twn.Completed:Connect(function()
			completed += 1
		end)
		fcompleted += 1
	end

	local twn
	twn = TWNs:Create(gui.zloading.text, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Size = UDim2.new()
	})
	twn:Play()
	twn.Completed:Connect(function()
		completed += 1
	end)
	fcompleted += 1

	repeat task.wait() until completed >= fcompleted

	gui.zloading.Visible = false
end)

sendSystemMessage({
	Text = "Welcome to the OCM browser!\nHappy Browsing!",
	Color = Color3.new(0.666667, 1, 0.52549),
	TextSize = 20
})

local figletR = figlets[math.random(1, #figlets)]:split("\n")
local figlet = {}
for _, x in pairs(figletR) do figlet[#figlet+1] = (" "):rep(35)..x end

game.TestService:Message(([[.
%s

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

    										                                        Welcome to the OCM Audio Browser!
    										                           All your errors in the console are automatially sent to gaben
    										                                                Happy Browsing!

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-]]):format(table.concat(figlet, "\n")))
game.LogService.MessageOut:Connect(function(msg, typ)
	if typ == Enum.MessageType.MessageError then
		game.ReplicatedStorage.events.tracking.LogError:FireServer(msg)
	end
end)

game.ReplicatedStorage.events.tracking.LogError.OnClientEvent:Connect(function()
	notifs("error")
end)

if not workspace.data.server.ready.Value then
	canint.protect("serverload")
	local pre = "Waiting for server to finish loading..."
	teleportingAppear(pre)

	local event = RNs.RenderStepped:Connect(function()
		gui.teleporting.text.Text = pre.."\n"..workspace.data.server.rstatus.Value
	end)
	repeat task.wait() until workspace.data.server.ready.Value
	event:Disconnect()

	canint.unprotect("serverload")
	teleportingDisappear()
end

local tpData = TPs:GetTeleportSetting("audioData")
if tpData then
	firstAud = false
	selectContainer(tpData.tabName)
	if tpData.tabQuery then gui.container.audios.searching.left.search.Text = tpData.tabQuery; task.wait() end
	if tpData.songId then
		local ui, sound = script.audio:Clone(), newSound()
		local hasInfo, info = game.ReplicatedStorage.events.tabs.audio.GetInfo:InvokeServer(tpData.songId)
		if hasInfo and info then
			ui, sound = loadSongUI(info, ui, sound)

			audtracker(sound, ui)
			if tpData.songLoop then auLooped = tpData.songLoop end
			if tpData.songTime then sound.TimePosition = tpData.songTime end
			if tpData.speedVal then gui.bgplayer.other.tempo.value.Text = tpData.speedVal end

			if tpData.songStatus then sound:Resume() end
			if tpData.spawnJam then doJam() end
		end
	end
end

local launchData = pgui:WaitForChild("launchData", 1337)
if launchData then
	local data = launchData.Value
	launchData:Destroy()

	local song = tonumber(data:match("play=(%d+)"))
	if song then
		local ui, sound = script.audio:Clone(), newSound()
		local hasInfo, info = game.ReplicatedStorage.events.tabs.audio.GetInfo:InvokeServer(song)

		if hasInfo and info then
			ui, sound = loadSongUI(info, ui, sound)

			audtracker(sound, ui)
			sound:Play()
		end
	end
end

repeat task.wait() until canint.check()

popup(
    "THIS GAME HAS BEEN ABANDONED.",
    "This game has been left abandoned for years, and will be superceded by a new service later in 2025." ..
    "\n\nHistorically, this game served a group where people can upload their own audio assets and listen to them during the March 2022 Great Purge." ..
    "\n\nIt is now terminated. We will not fix this version of the browser or the group." ..
    "\n\nIf something infringes on your copyright, please contact either znotfireman/nexpid on Discord (ImNotFireMan123/GABA8 on Roblox) so we'll remove it from our archive API dump." ..
    "\n\nThe group data has been open sourced at GitHub repositories roblaudio/ocmusic-v2-api-dump and a developing roblaudio/ocmusic-api-dumb. We'll open source this browser later." ..
    "\n\nThanks for everything, and see you all sometime soon.",
    { "o7" }
)
