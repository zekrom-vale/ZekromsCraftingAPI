require "/scripts/ZekromsUtil.lua"
Zcontainer={}

function Zcontainer.tryAdd(items)
	if type(items)~="table" or next(items)==nil then
		return nil
	else
		return Zcontainer.addItems(items)
	end
end

function Zcontainer.addItems(pass)
	item=Zutil.deepcopy(pass)
	local id=entity.id()
	local arr={}
	for _,item in pairs(items) do
		local t=Zcontainer.putAt(item, self.output)
		if type(t)=="table" then table.insert(arr, t) end
	end
	return arr
end

function Zcontainer.treasure(pass)
	local items=Zutil.deepcopy(pass)
	for key,item in pairs(items) do
		if item.pool~=nil then
			local pool=root.createTreasure(item.pool, item.level or 0)
			table.remove(items, key)
			key=key-1
			for _,val in pairs(pool) do
				table.insert(items, val)
			end
		end
	end
	return items
end

function Zcontainer.consumeAt(pass, range)
	item=Zutil.deepcopy(pass)
	local stack=world.containerItems(entity.id())
	for offset=range[1],range[2] do
		if stack[offset]~=nil and stack[offset]["name"]==item.name then
			if stack[offset]["count"]>=item.count then
				world.containerConsumeAt(entity.id(), offset-1, item.count)
				return true
			end
			item.count=item.count-stack[offset]["count"]
			world.containerTakeAt(entity.id(), offset)
		end
	end
	return false
end

function Zcontainer.putAt(pass, range)
	item=Zutil.deepcopy(pass)
	local stack=world.containerItems(entity.id())
	for offset=range[1],range[2] do
		if stack[offset]==nil or stack[offset]["name"]==item.name then
			item=world.containerPutItemsAt(entity.id(), item, offset-1)
			if item==nil or next(item)==nil or item.count<=0 then
				return true
			end
		end
	end
	return item
end

function Zcontainer.canFitAt(pass, range)
	item=Zutil.deepcopy(pass)
	local stack=world.containerItems(entity.id())
	for offset=range[1],range[2] do
		if stack[offset]==nil or stack[offset]["name"]==item.name then
			item=world.containerPutItemsAt(entity.id(), item, offset-1)
			local ok=world.containerSwapItemsNoCombine(entity.id(), stack[offset], offset-1)
			if ok==false then
				Zutil.API()
				sb.logWarn("Item duplicated at: "..Zutil.sbName())
				sb.logWarn("Item name: " item.name)
			end
		end
	end
	if item==nil or next(item)==nil or item.count>=0 then
		return true
	end
	return false
end