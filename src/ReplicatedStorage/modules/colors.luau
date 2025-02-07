local function seq(...)
	local obj = {}

	local lim = {...}
	for i, x in pairs(lim) do
		local wool = (i-1)/(#lim-1)
		obj[#obj+1] = ColorSequenceKeypoint.new(wool, Color3.fromHex(x))
	end
	return ColorSequence.new(obj)
end

return {
	colorsOrder = ("auto blend  institutional white  bright red  bright blue  earth green  bright violet  bright orange  bright yellow  light reddish violet  brick yellow"):split("  "),
	colors = {
		["auto blend"] = Color3.new(),
		["institutional white"] = BrickColor.new("Institutional white").Color,
		["bright red"] = BrickColor.new("Bright red").Color,
		["bright blue"] = BrickColor.new("Bright blue").Color,
		["earth green"] = BrickColor.new("Earth green").Color,
		["bright violet"] = BrickColor.new("Bright violet").Color,
		["bright orange"] = BrickColor.new("Bright orange").Color,
		["bright yellow"] = BrickColor.new("Bright yellow").Color,
		["light reddish violet"] = BrickColor.new("Light reddish violet").Color,
		["brick yellow"] = BrickColor.new("Brick yellow").Color
	},
	gradientsOrder = ("gradient auto blend  rainbow  mint apple  citrus  retro  hanami  candyfloss  mars  sunrise  neon  green tea"):split("  "),
	gradients = {
		["gradient auto blend"] = seq("000000", "000000"),
		["rainbow"] = ColorSequence.new({
			ColorSequenceKeypoint.new(0.0, Color3.fromHSV(0, 1, 1)),
			ColorSequenceKeypoint.new(0.1, Color3.fromHSV(0.1, 1, 1)),
			ColorSequenceKeypoint.new(0.2, Color3.fromHSV(0.2, 1, 1)),
			ColorSequenceKeypoint.new(0.3, Color3.fromHSV(0.3, 1, 1)),
			ColorSequenceKeypoint.new(0.4, Color3.fromHSV(0.4, 1, 1)),
			ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
			ColorSequenceKeypoint.new(0.6, Color3.fromHSV(0.6, 1, 1)),
			ColorSequenceKeypoint.new(0.7, Color3.fromHSV(0.7, 1, 1)),
			ColorSequenceKeypoint.new(0.8, Color3.fromHSV(0.8, 1, 1)),
			ColorSequenceKeypoint.new(0.9, Color3.fromHSV(0.9, 1, 1)),
			ColorSequenceKeypoint.new(1.0, Color3.fromHSV(1, 1, 1))
		}),
		["mint apple"] = seq("bcd8cd", "d4e5b4"),
		["citrus"] = seq("eedb9e", "e9ad9b"),
		["retro"] = seq("bbbdd8", "abbbcf"),
		["hanami"] = seq("daedd1", "f0e1d3"),
		["candyfloss"] = seq("f0d7dd", "d1dcfd"),
		["mars"] = seq("fda33c", "ff6600"),
		["sunrise"] = seq("e16363", "ffd692"),
		["neon"] = seq("ab93c9", "d698b9"),
		["green tea"] = seq("b9ffb4", "f6efee"),
	},
	rarities = {
		free = Color3.new(0.737255, 0.737255, 0.737255),
		easy = Color3.new(0.623529, 1, 0.521569),
		medium = Color3.new(0.976471, 1, 0.505882),
		hard = Color3.new(1, 0.717647, 0.470588),
		impossible = Color3.new(0.631373, 0.384314, 1),
		extraordinary = Color3.new(0.819608, 0.819608, 0.819608)
	},
	badges = {
		["bug reporter"] = seq("226ee6", "ff0081"),
		["exploiter"] = seq("be1d1d", "e73c3c"),
		["???"] = seq("3c00c8", "8b81a4"),
		["obsessed"] = seq("e0c134", "17d720"),
		["undertale addict"] = seq("00d0e0", "ffffff"),
		["birthday"] = seq("ff6961", "77dd77"),
		["suggester"] = seq("c4fff3", "f5ff73"),
		["witnessed gaben"] = seq("f69ee8", "61154f"),
		["witnessed tophat"] = seq("8b59ff", "e413eb"),
		["witnessed fire"] = seq("fc3737", "eb6d13"),
		["witnessed mario"] = seq("22e63c", "00b1ff"),
		["april fooled"] = seq("000000", "000000")
	}
}
