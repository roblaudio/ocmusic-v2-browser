local statz = require(game.ServerStorage.stats)

for _, x: TextChatCommand in pairs(game.ServerStorage["chat commands"]:GetDescendants()) do
	if not x:IsA("TextChatCommand") then continue end
	local y = x:Clone()
	y.Name = "OCM"..x.Name.."Command"
	for z in pairs(y:GetAttributes()) do
		y:SetAttribute(z)
	end
	y:SetAttribute("hey", "hi exploiter")
	y.Triggered:Connect(function(source: TextSource, text: string)
		local plr
		for _, x: Player in pairs(game.Players:GetChildren()) do
			if x.UserId == source.UserId then plr = x end
		end
		if not plr then return end

		statz.chat.handleCommand(plr, x, text)
	end)
	y.Parent = game.TextChatService.TextChatCommands
end
