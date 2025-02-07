_G.ci = _G.ci or {}

return {
	protect = function(key: string)
		if not table.find(_G.ci, key) then table.insert(_G.ci, key) end
	end,
	unprotect = function(key: string)
		if table.find(_G.ci, key) then table.remove(_G.ci, table.find(_G.ci, key)) end
	end,
	isprotect = function(key: string)
		return not not table.find(_G.ci, key)
	end,
	getprotects = function()
		return _G.ci
	end,
	unprotectAll = function()
		_G.ci = {}
	end,
	check = function(...)
		local ga = {unpack(_G.ci)}
		for _, j in pairs({...}) do table.remove(ga, table.find(ga, j)) end

		return #ga == 0
	end,
}
