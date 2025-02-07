local tweens = game:GetService("TweenService")
local texts = game:GetService("TextService")
local runs = game:GetService("RunService")
local canint = require(game.ReplicatedStorage.modules.CanInteract)
local plr = game.Players.LocalPlayer

_G.lastPopup = 0

return function(title: string, message: string, answers: {string}, stepped, ran)
	local gui = plr.PlayerGui.main.popup

	canint.protect("popup")
	gui.frame.Size = UDim2.new(0.5, 0, 0.6, 0)
	gui.frame.title.Text = title:upper()
	gui.Visible = true

	local soz = 0.09
	local saz = soz*gui.frame.AbsoluteSize.Y
	local sz = texts:GetTextSize(message, saz, Enum.Font.Highway, Vector2.new(gui.frame.AbsoluteSize.X, 99999))
	gui.frame.Size = UDim2.new()
	gui.frame.desc.Size = UDim2.new(1, 0, math.round(sz.Y/saz)*soz, 0)
	gui.frame.desc.Text = message

	local popup = tick()
	_G.lastPopup = popup

	for _, b in pairs(gui.frame.buttons:GetChildren()) do
		if b:IsA("TextButton") then b:Destroy() end
	end

	local function makeStuff(direction, data, data2)
		local inf = TweenInfo.new(0.5, Enum.EasingStyle.Back, direction)
		local twen, twen2 = tweens:Create(gui, inf, data), tweens:Create(gui.frame, inf, data2)
		twen:Play()
		twen2:Play()
		return twen
	end

	makeStuff(Enum.EasingDirection.Out, {
		BackgroundTransparency = 0.5
	}, {
		Size = UDim2.new(0.5, 0, 0.6, 0)
	})
	local vsb = false

	local events = {}
	local bats = {}
	for i, a in pairs(answers) do
		local b = script.btn:Clone()
		b.Size = UDim2.new(1/#answers, 0, 1, 0)
		b.Text = a
		b.Parent = gui.frame.buttons
		b.LayoutOrder = i
		b.Name = a
		bats[i] = b
		table.insert(events, b.Activated:Connect(function()
			if ran and not ran(a) then return end
			vsb = a
		end))
	end
	runs.RenderStepped:Connect(function()
		if _G.lastPopup == popup then
			if stepped then
				local lol = stepped()
				for i, a in pairs(lol) do
					if bats[i] then
						bats[i].Text = a
					end
				end
			end
		end
	end)

	repeat task.wait() until vsb~=false or _G.lastPopup ~= popup
	for _, e in pairs(events) do e:Disconnect() end

	if _G.lastPopup ~= popup then return end

	task.spawn(function()
		canint.unprotect("popup")

		makeStuff(Enum.EasingDirection.In, {
			BackgroundTransparency = 1
		}, {
			Size = UDim2.new()
		}).Completed:Wait()
		if _G.lastPopup ~= popup then return end
		gui.Visible = false
	end)

	return vsb
end
