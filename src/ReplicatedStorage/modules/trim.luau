local chars = ([[

 
 
 
 
 
 
 
 
 
 
 
 
 
　
᠎
​
‍
⁠
]]):gsub("\n", ""):split("")

return function(str: string)
	if typeof(str) ~= "string" then return end

	local jo = str:split("")
	local i = 1
	while true do
		if i > #jo then break end
		local x = jo[i]
		if table.find(chars, x) then table.remove(jo, i); i -= 1 end
		i += 1
	end
	str = table.concat(jo, "")

	while str:find("   ") do
		str = str:gsub("   ", "  ")
	end
	while str:find("\n\n") do
		str = str:gsub("\n\n", "\n")
	end

	return str:gsub("^%s+", ""):gsub("%s+$", "")
end
