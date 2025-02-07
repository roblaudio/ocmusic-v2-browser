local tweens = game:GetService("TweenService")
local texts = game:GetService("TextService")

_G.ha = 0
return function(typ: string, info: string?)
	local title, desc, tim = "", "", 5

	if typ == "badge" then
		title = `🎖 Awarded "{info or ""}"!`
		desc = "Check it out in the \"Badges\" tab!"
		tim = 9
	elseif typ == "cooldown" then
		title = "❄️ Cooldown"
		desc = `You are on cooldown for {info or ""}.`
		tim = 5
	elseif typ == "error" then
		title = "❌ Error"
		desc = "Don't fret! The error has been sent to the developer to be fixed."
		tim = 6
	elseif typ == "socialyes" then
		title = "👥 Listening"
		desc = `Now listening along with @{info or ""}!`
		tim = 4
	elseif typ == "socialno" then
		title = "👤 Not Listening"
		desc = `No longer listening along with @{info or ""}.`
		tim = 3
	end

	_G.ha += 1

	local ui = game:GetService("RunService"):IsRunning() and game.Players.LocalPlayer.PlayerGui.main or game.StarterGui.main
	local s = script.notification:Clone()
	s.Parent = ui.notifications

	local soz = 0.2
	local saz = soz*s.AbsoluteSize.Y
	local sz = texts:GetTextSize(desc, saz, Enum.Font.Highway, Vector2.new(s.AbsoluteSize.X, 99999))

	s.main.stuff.desc.Size = UDim2.new(1, 0, math.round(sz.Y/saz)*soz, 0)
	s.main.stuff.desc.Text = desc

	task.spawn(function()
		while s.Parent do
			s.main.Size = UDim2.new(1, 0, 0, ui.notifications.AbsoluteSize.Y*0.2)
			task.wait()
		end
	end)

	s.LayoutOrder = -_G.ha
	s.Size = UDim2.new(1, 0, 0, 0)
	s.main.Position = UDim2.new(1, 0, 0, 0)
	s.main.stuff.title.Text = title
	tweens:Create(s, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 0.2, 0)
	}):Play()
	tweens:Create(s.main, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()
	task.wait(0.55)
	tweens:Create(s.main.line, TweenInfo.new(tim, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
		Size = UDim2.new(0, 0, 0.035, 0)
	}):Play()
	task.wait(tim+0.05)
	tweens:Create(s, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		Size = UDim2.new(1, 0, 0, 0)
	}):Play()
	tweens:Create(s.main, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, 0, 0, 0)
	}):Play()
	task.wait(0.55)
	s:Destroy()
end
