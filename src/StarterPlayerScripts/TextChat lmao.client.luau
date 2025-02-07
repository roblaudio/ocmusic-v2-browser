local precolors = require(game.ReplicatedStorage.modules.colors)
local chatTools = require(game.ReplicatedStorage.modules.chatTools)
local unicode = require(game.ReplicatedStorage.modules.unicode)
local TCs = game:GetService("TextChatService")
local HTTPs = game:GetService("HttpService")

TCs.OnIncomingMessage = function(message: TextChatMessage)
	local props = Instance.new("TextChatMessageProperties")
	props.Text = message.Text
	props.PrefixText = message.PrefixText

	if message.TextSource then
		local plr
		for _, x: Player in pairs(game.Players:GetChildren()) do
			if x.UserId == message.TextSource.UserId then plr = x end
		end
		if not plr then return end

		local chatColor = plr:GetAttribute("chChatColor") or Color3.new(1, 1, 1)
		local nameColor = plr:GetAttribute("chNameColor") or chatTools:GetChatColor(message.TextSource.Name)

		local tog, tags = pcall(HTTPs.JSONDecode, HTTPs, plr:GetAttribute("chTags"))
		if not tog then tags = {} end

		local formatted = {}
		for _, t: { text: string, color: string, hidden: boolean? } in pairs(tags) do
			if t.hidden then continue end

			table.insert(formatted, chatTools:ChooseRichify(chatTools:GetTagDisplay(t.text), chatTools:GetTagColor(t)))
		end

		local tagz = formatted[1] and (table.concat(formatted, " ") .. " ") or ""

		local name = chatTools:GetNameDisplay(plr.DisplayName)
		props.PrefixText = chatTools:ChooseRichify(name, nameColor)

		if plr.MembershipType == Enum.MembershipType.Premium then
			props.PrefixText = `<font color="#ffffff">{unicode.premium}</font> {props.PrefixText}`
		end

		local pinged = false
		local function matchForW(x)
			local converted = "@"
			for _, y in pairs(x:split("")) do
				if y:lower() ~= y:upper() then converted ..= `[{y:upper()}{y:lower()}]`
				else converted ..= y end
			end

			props.Text = props.Text:gsub(converted, function() pinged = true; return `<u><font color="#7cd1f7" weight="Bold">@{x}</font></u>` end)
		end

		matchForW(plr.DisplayName)
		matchForW(plr.Name)
		if pinged and not _G.focused then
			script.Parent.MainScript.sfx.ping:Play()
		end

		props.PrefixText = tagz .. props.PrefixText
		props.Text = chatTools:Richify(props.Text, chatColor, true)
	end

	pcall(function()
		local data = {}
		for _, x in pairs(message.Metadata:split(";;")) do
			local y = x:split(";")
			if not y[1] or not y[2] then continue end

			data[#data+1] = `{y[1]}="{y[2]}"`
		end

		if data[1] then
			props.Text = `<font {table.concat(data, " ")}>{props.Text}</font>`
		end
	end)

	return props
end
