require"/scripts/ZekromsUtil.lua"
Zcontainer={}

function Zcontainer.tryAdd(items)
	if type(items)=="table"and next(items)then
		return Zcontainer.addItems(items)
	end
end

function Zcontainer.addItems(items)
	local id,arr=entity.id(),{}
	for _,item in pairs(items)do
		local t=Zcontainer.putAt(item,self.output)
		if type(t)=="table"then	table.insert(arr,t)	end
	end
	return arr
end

function Zcontainer.treasure(orig)
	items=Zutil.deepcopy(orig)
	for key,item in pairs(items)do
		if item.pool then
			table.remove(items,key)
			key=key-1
			for _,val in pairs(root.createTreasure(item.pool,item.level or 0))do
				table.insert(items,val)
			end
		end
	end
	return items
end

function Zcontainer.consumeAt(item,range)
	if not item.name and item.names then	return	end
	local id=entity.id()
	local stack=world.containerItems(id)
	for o=table.unpack(range)do
		if stack[o]and root.itemDescriptorsMatch(stack[o],item)then
			if stack[o].count>=item.count then
				world.containerConsumeAt(id,o-1,item.count)
				return true
			end
			item.count=item.count-stack[o].count
			world.containerTakeAt(id,o)
		end
	end
	return false
end

function Zcontainer.putAt(item,range)
	local id=entity.id()
	local stack=world.containerItems(id)
	for o=table.unpack(range)do
		if not stack[o]or root.itemDescriptorsMatch(stack[o],item)then
			item=world.containerPutItemsAt(id,item,o-1)
			if not(item and next(item))or item.count<=0 then
				return true
			end
		end
	end
	return item
end

--[[function Zcontainer.canFitAt(pass, range)
	item=Zutil.deepcopy(pass)
	local stack=world.containerItems(entity.id())
	for offset=table.unpack(range)do
		if stack[offset]==nil or stack[offset]["name"]==item.name then
			item=world.containerPutItemsAt(entity.id(), item, offset-1)
			local ok=world.containerSwapItemsNoCombine(entity.id(), stack[offset], offset-1)
			if not ok then
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
end]]

function Zcontainer.occupied(range)
	local stacks=world.containerItems(entity.id())
	for o=table.unpack(self.output) do
		if stacks[o] then	return true	end
	end
end