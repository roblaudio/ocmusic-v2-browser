local presetColors = require(game.ReplicatedStorage.modules.colors)
local HTTPs = game:GetService("HttpService")

local obj = {}

function obj:GetChatColor(name: string)
	local colors = {
		BrickColor.new("Bright red").Color,
		BrickColor.new("Bright blue").Color,
		BrickColor.new("Earth green").Color,
		BrickColor.new("Bright violet").Color,
		BrickColor.new("Bright orange").Color,
		BrickColor.new("Bright yellow").Color,
		BrickColor.new("Light reddish violet").Color,
		BrickColor.new("Brick yellow").Color,
	}

	local function nameVal(pName)
		local value = 0
		for index = 1, #pName do
			local cValue = string.byte(string.sub(pName, index, index))
			local reverseIndex = #pName - index + 1
			if #pName%2 == 1 then
				reverseIndex = reverseIndex - 1
			end
			if reverseIndex%4 >= 2 then
				cValue = -cValue
			end
			value = value + cValue
		end
		return value
	end

	local color = colors[((nameVal(name)) % #colors) + 1]
	return color
end

function obj:UnrichEncode(str: string)
	str = str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub("'", "&apos;")
	return str
end

function obj:Richify(str: string, color, nounrich)
	return `<font color="#{color:ToHex()}">{nounrich and str or obj:UnrichEncode(str)}</font>`
end
function obj:GradientRichify(str: string, seq: ColorSequence, nounrich)
	local function getColorAtTime(tm)
		if tm == 0 then
			return seq.Keypoints[1].Value
		elseif tm == 1 then
			return seq.Keypoints[#seq.Keypoints].Value
		end

		for i, x in pairs(seq.Keypoints) do
			local nex = seq.Keypoints[i+1]
			if not nex then continue end
			if (tm >= x.Time and tm < nex.Time) then
				local alpha = (tm - x.Time) / (nex.Time - x.Time)
				return x.Value:Lerp(nex.Value, alpha)
			end
		end
	end

	local ret, max = "", #str-1
	for i = 0, max do
		ret ..= obj:Richify(str:sub(i+1,i+1), getColorAtTime(i/max), nounrich)
	end

	return ret
end
function obj:ChooseRichify(str: string, color: Color3|ColorSequence, nounrich)
	return typeof(color) == "ColorSequence"
		and obj:GradientRichify(str, color, nounrich)
		or obj:Richify(str, color, nounrich)
end

function obj:ConvertColor(obj: Color3|ColorSequence)
	if typeof(obj) == "Color3" then return {"clr3", obj:ToHex()}
	elseif typeof(obj) == "ColorSequence" then
		local seqq = {}
		for _, x in pairs(obj.Keypoints) do seqq[#seqq+1] = {x.Time, x.Value:ToHex()} end
		return {"clrseq", seqq}
	end
end
function obj:UnconvertColor(obj: {})
	if obj[1] == "clr3" then return Color3.fromHex(obj[2])
	elseif obj[1] == "clrseq" then
		local seqq = {}
		for _, x in pairs(obj[2]) do seqq[#seqq+1] = ColorSequenceKeypoint.new(x[1], Color3.fromHex(x[2])) end
		return ColorSequence.new(seqq)
	end
end

function obj:GetTagDisplay(tag)
	return workspace.data.server.cbrackets.Value and `{tag}` or tag
end
function obj:GetNameDisplay(name)
	return workspace.data.server.cbrackets.Value and `[{name}]:` or `{name}:`
end

function obj:SequenceToColor(seq: ColorSequence)
	return seq.Keypoints[1].Value:Lerp(seq.Keypoints[#seq.Keypoints].Value, 0.5)
end

function obj:GetFrank(tags: {})
	local frank
	for _, x in pairs(tags) do
		if not x.hidden then
			local preset = presetColors.badges[x.text] or presetColors.rarities.free
			frank = x.color == "badge" and preset or Color3.fromHex(x.color)
		end
	end
	return frank
end
function obj:BlendBehind(frank, to)
	local from
	if frank then
		if typeof(frank) == "ColorSequence" then from = frank.Keypoints[#frank.Keypoints].Value
		else from = frank end
	else from = to:Lerp(Color3.new(1, 1, 1), 0.6) end

	return from
end
function obj:MakeBlendGradient(tags: {}, to: Color3)
	local from = obj:BlendBehind(obj:GetFrank(tags), to)

	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, from),
		ColorSequenceKeypoint.new(1, to)
	})
end
function obj:MakeBlend(tags: {}, to: Color3)
	local from = obj:BlendBehind(obj:GetFrank(tags), to)

	return from:Lerp(to, 0.5)
end
function obj:GetChatColorFromTags(tags: {})
	local frank = obj:GetFrank(tags)
	if typeof(frank) == "ColorSequence" then frank = obj:SequenceToColor(frank) end

	if frank then return frank:Lerp(Color3.new(1, 1, 1), 0.6)
	else return Color3.new(1, 1, 1) end
end
function obj:GetTagColor(tag)
	local color
	local preset = presetColors.badges[tag.text] or presetColors.rarities.free

	return tag.color == "badge" and preset or Color3.fromHex(tag.color)
end

function obj:RenderNameColor(username, nameColor, tags, chatColor)
	local clr = presetColors.colors[nameColor] or presetColors.gradients[nameColor]
	if not clr then return obj:GetChatColor(username) end

	if nameColor == "auto blend" then
		clr = obj:MakeBlend(tags, chatColor)
	elseif nameColor == "gradient auto blend" then
		clr = obj:MakeBlendGradient(tags, chatColor)
	end

	return clr
end

function obj:GetLocalTags()
	local tagged, rawTags = pcall(HTTPs.JSONDecode, HTTPs, game.Players.LocalPlayer:GetAttribute("chTags"))
	if not tagged or not rawTags then return {} end
	return rawTags
end

return obj
