require "/scripts/ZekromsContainerUtil.lua"
require "/scripts/ZekromsUtil.lua"
require "/scripts/ZekromsItemUtil.lua"
function init()
	storage.clock= storage.clock or 0
	self.input=config.getParameter("multicraftAPI.input", {1, size})
	self.output=config.getParameter("multicraftAPI.output", {1, size})
	self.recipes=root.assetJson(config.getParameter("multicraftAPI.recipefile"),{})
	self.clockMax=math.floor(config.getParameter("multicraftAPI.clockMax",10000))
	self.level=config.getParameter("multicraftAPI.level", 1)
	self.init=true
end

function verify()
	local import=self
	if #import.input>2 or #import.output>2 then
		Zutil.API()
		sb.logInfo("Input/output array is not 2 elements for: "..Zutil.sbName()..".  Ignoring the other ones")
	end
	local size=world.containerSize(entity.id())
	self.input={fixIO(import.input[1],size) or 1, fixIO(import.input[2],size) or size}
	self.output={fixIO(import.output[1],size) or 1, fixIO(import.output[2],size) or size}
	size=nil

	if import.input[1]>import.input[2] then
		local t=import.input[1]
		self.input[1]=import.input[2]
		self.input[2]=t
		t=nil
		Zutil.API()
		sb.logInfo("Input values swapped, please use [small, large] for: "..Zutil.sbName())
	end
	if import.output[1]>import.output[2] then
		local t=import.output[1]
		self.output[1]=import.output[2]
		self.output[2]=t
		t=nil
		Zutil.API()
		sb.logInfo("Output values swapped, please use [small, large] for: "..Zutil.sbName())
	end
	verifyIn()
	if next(import.recipes)==nil then
		Zutil.API()
		sb.logError("No recipe file defined for: "..Zutil.sbName())
	end
end

function fixIO(item,size)
	if item==nil or type(item)~="number" then
		Zutil.API()
		sb.logWarn("Input/output array is not 2 elements for: "..Zutil.sbName()..".  Trying to compensate")
	elseif item%1~=0 or item>size or item<=0 then
		Zutil.API()
		sb.logWarn("Input/output invalid: "..Zutil.sbName()..".  Trying to compensate")
	else
		return item
	end
end

function verifyIn()
	local act=function(value,key)
		sb.logInfo(sb.printJson(value,1))
		table.remove(self.recipes, key)
		return key-1
	end
	for key,value in pairs(self.recipes) do
		if (value.level or 1)>self.level then 
			table.remove(self.recipes, key)
			key=key-1
			goto testEnd
		elseif value.input==nil or value.output==nil then
			Zutil.API(); sb.logWarn("Input/output missing for: "..Zutil.sbName())
			key=act(value,key)
			goto testEnd
		elseif #value.input>self.input[2]-self.input[1]+1 then
			Zutil.API(); sb.logWarn("Input overflow in: "..Zutil.sbName())
			key=act(value,key)
			goto testEnd
		elseif #value.output>self.output[2]-self.output[1]+1 then
			Zutil.API(); sb.logInfo("Output overflow in: "..Zutil.sbName())
			sb.logInfo(sb.printJson(value,1))
		end
		if value.delay~=nil and value.delay%1~=0 then
			Zutil.API(); sb.logInfo("Dellay is not an 'int' in: "..Zutil.sbName())
			sb.logInfo(sb.printJson(value,1))
			value.delay=math.floor(value.delay)
		end
		for _,out in pairs(value.output) do
			if out.pool~=nil and not root.isTreasurePool(out.pool) then
				Zutil.API()
				sb.logWarn("Invalid pool in: "..Zutil.sbName())
				key=act(value,key)
				break
			end
		end
		::testEnd::
	end
end

function update(dt)
	if self.init then
		verify()
		self.init=false
	end
	storage.clock=(storage.clock+1)%self.clockMax
	if storage.wait~=nil then
		if storage.wait==storage.clock then
			storage.overflow=Zcontainer.tryAdd(storage.overflow)
			storage.wait=nil
		end
		return
	end
	storage.overflow=Zcontainer.tryAdd(storage.overflow)
	if type(storage.overflow)~="table" then
		local stack=world.containerItems(entity.id())
		for _,value in pairs(self.recipes) do
			if value.shaped then
				storage.overflow=consumeItemsShaped(value.input, value.output, stack, value.delay)
			else
				storage.overflow=consumeItems(value.input, value.output, stack, value.delay)
			end
			if storage.overflow~=false then	break	end
		end
	end
end

function consumeItemsShaped(items, prod, stacks, delay)
	local item2={}
	for k,item in pairs(items) do
		local stack=stacks[k+self.input[1]-1]
		if stack==nil then	return false	end
		if not(root.itemDescriptorsMatch(stack, item) and item.count<=stack.count) then
			if item.names~=nil and item.count<=stack.count then
				for _,ilist in pairs(item.names) do
					local obj= Zutil.deepcopy(item)
					obj.names,obj.name=nil,ilist
					if root.itemDescriptorsMatch(stack[index], obj) then
						counts=counts+stack[index].count
						table.insert(item2, obj)
					end
				end
			else
				return false
			end
		end
	end
	return tail(items, item2, prod)
end

function consumeItems(items, prod, stack, delay)
	local item2={}
	for _,item in pairs(items) do
		if true then
			local counts=0
			for i=self.input[1],self.input[2] do
				if item.names~=nil then
					for _,val in pairs(item.names) do
						local obj= Zutil.deepcopy(item)
						obj.names=nil
						obj.name=val
						if root.itemDescriptorsMatch(stack[i], obj) then
							counts=counts+stack[i].count
							table.insert(item2, obj)
							if item.count<=counts then	goto skip	end
						end
					end
				elseif root.itemDescriptorsMatch(stack[i], item) then
					counts=counts+stack[i].count
					if item.count<=counts then	goto skip	end
				end
			end
			return false
		end
		::skip::
	end
	return tail(items, item2, prod)
end

function tail(items, item2, prod)
	local function loop(items)
		for _,item in pairs(items) do
			if type(item.damage)=="number" then
				Zitem.damage(item)
			elseif item.consume~=false then
				Zcontainer.consumeAt(item, self.input)
			end
		end
	end
	loop(items)
	loop(item2)
	prod=Zcontainer.treasure(prod)
	if delayKey(delay) then
		return prod
	end
	return Zcontainer.addItems(prod)
end

function delayKey(delay)
	if delay~=nil and delay~=0 then
		storage.wait=(storage.clock+delay)%self.clockMax
		return true
	end
end

function die()
	local poz=entity.position()
	local function drop(poz)
		for _,item in pairs(storage.overflow) do
			world.spawnItem(item.name, poz, item.count)
		end
	end
	if config.getParameter("multicraftAPI.killStorage") or (type(storage.wait)=="number" and storage.wait~=0) then
		local drop=config.getParameter("multicraftAPI.drop", "all")
		if drop=="none" or drop==0 then
			return
		elseif type(drop)=="number" then
			if drop>0 then
				for _,item in pairs(storage.overflow) do
					world.spawnItem(item.name, poz, math.ceil(item.count*drop))
				end
			else
				for _,item in pairs(storage.overflow) do
					world.spawnItem(item.name, poz, math.floor(item.count*-drop))
				end
			end
		else
			drop(poz)
		end
	else
		drop(poz)
	end
end