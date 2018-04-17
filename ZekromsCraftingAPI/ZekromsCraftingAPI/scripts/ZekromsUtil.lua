Zutil={}

--http://lua-users.org/wiki/CopyTable
function Zutil.deepcopy(orig)
	local copy
	if type(orig)=='table' then
		copy={}
		for orig_key,orig_value in next, orig, nil do
			copy[Zutil.deepcopy(orig_key)]=Zutil.deepcopy(orig_value)
		end
		setmetatable(copy, Zutil.deepcopy(getmetatable(orig)))
	else
		return orig
	end
	return copy
end

function Zutil.sbName()
	local name=config.getParameter("objectName")
	if name~=nil then	name=config.getParameter("itemName")	end
	return "'"..(name or "null").."'.  id: '"..(entity.id() or "null").."'"
end

function Zutil.API()
	sb.logInfo("---  API mod: 'ZekromsMulticraftAPI'  ---")
end