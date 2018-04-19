require "/scripts/ZekromsContainerUtil.lua"
require "/scripts/ZekromsUtil.lua"
require "/scripts/ZekromsItemUtil.lua"
function init()
	if storage.clock==nil then
		storage.clock=0
	end
	self.input=config.getParameter("multicraftAPI.input", {1, size})
	self.output=config.getParameter("multicraftAPI.output", {1, size})
	self.recipes=root.assetJson(config.getParameter("multicraftAPI.recipefile"),{})
	self.clockMax=math.floor(config.getParameter("multicraftAPI.clockMax",10000))
	self.trigger=getTrigger()
	sb.logInfo(tostring(self.trigger))
	self.init=true
end

function getTrigger()
	sb.logInfo(sb.printJson(root.assetJson(config.getParameter("uiConfig")),1))
	for _,value in pairs(root.assetJson(config.getParameter("uiConfig")).scripts) do
		if value=="/scripts/ZekTrigger.lua" then
			return true
		end
	end
	return false
end

function verify()
	if #self.input>2 or #self.output>2 then
		Zutil.API()
		sb.logInfo("Input/output array is not 2 elements for: "..Zutil.sbName()..".  Ignoring the other ones")
	end
	local size=world.containerSize(entity.id())
	self.input={fixIO(self.input[1],size) or 1, fixIO(self.input[2],size) or size}
	self.output={fixIO(self.output[1],size) or 1, fixIO(self.output[2],size) or size}

	if self.input[1]>self.input[2] then
		local t=self.input[2]
		self.input[1]=self.input[2]
		self.input[2]=t
		t=nil
		Zutil.API()
		sb.logInfo("Input values swapped, please use [small, large] for: "..Zutil.sbName())
	end
	if self.output[1]>self.output[2] then
		local t=self.output[2]
		self.output[1]=self.output[2]
		self.output[2]=t
		t=nil
		Zutil.API()
		sb.logInfo("Output values swapped, please use [small, large] for: "..Zutil.sbName())
	end
	verifyIn()
	if next(self.recipes)==nil then
		Zutil.API()
		sb.logError("No recipe file defined for: "..Zutil.sbName())
	end
end

function fixIO(item,size)
	local ran,val=pcall(pcallFixIO, item, size)
	if ran then
		return val
	else
		Zutil.API()
		sb.logWarn("pcall failed at: "..Zutil.sbName())
		return item
	end
end

function pcallFixIO(item,size)
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
		if value.input==nil or value.output==nil then
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
			if out.pool==nil then	break	end
			if not root.isTreasurePool(out.pool) then
				Zutil.API()
				sb.logWarn("Invalid pool in: "..Zutil.sbName())
				key=act(value,key)
				goto testEnd
			end
		end
		::testEnd::
	end
end

function update(dt)
	sb.logInfo(tostring(storage.active))
	if self.init then
		verify()
		self.init=false
	end
	if self.trigger==true and storage.active~=true then
		return
	end
	storage.clock=(storage.clock+1)%self.clockMax
	if storage.wait~=nil and storage.wait==storage.clock then
		storage.overflow=Zcontainer.tryAdd(storage.overflow)
		storage.wait=nil
		return
	elseif storage.wait~=nil then
		return
	end
	storage.overflow=Zcontainer.tryAdd(storage.overflow)
	if type(storage.overflow)~="table" then
		local stack=world.containerItems(entity.id())
		for _,value in pairs(self.recipes) do
			if value.shaped then
				storage.overflow=consumeItemsShaped(value.input, value.output, stack, value.delay)
				if storage.overflow~=false then	break	end
			else
				storage.overflow=consumeItems(value.input, value.output, stack, value.delay)
				if storage.overflow~=false then	break	end
			end
		end
	elseif self.trigger==true then
		storage.active=false
	end
end

function consumeItemsShaped(items, prod, stacks, delay)
	local item2={}
	for key,item in pairs(items) do
		local stack=stacks[key+self.input[1]-1]
		if stack==nil then	return false	end
		if not(root.itemDescriptorsMatch(stack, item) and item.count<=stack.count) then
			if item.names~=nil and item.count<=stack.count then
				for _,ilist in pairs(item.names) do
					local obj= Zutil.deepcopy(item)
					obj.names=nil
					obj.name=ilist
					if root.itemDescriptorsMatch(stack[index], obj) then
						counts=counts+stack[index]["count"]
						table.insert(item2, obj)
					end
				end
			else
				return false
			end
		end
	end
	for _,item in pairs(items) do
		if type(item.damage)=="number" then
			Zitem.damage(item)
		elseif item.consume~=false then
			Zcontainer.consumeAt(item, self.input)
		end
	end
	for _,item in pairs(item2) do
		if type(item.damage)=="number" then
			Zitem.damage(item)
		elseif item.consume~=false then
			Zcontainer.consumeAt(item, self.input)
		end
	end
	prod=Zcontainer.treasure(prod)
	if delayKey(delay) then
		return prod
	end
	return Zcontainer.addItems(prod)
end

function consumeItems(items, prod, stack, delay)
	local item2={}
	for _,item in pairs(items) do
		if true then
			local counts=0
			for index=self.input[1],self.input[2] do
				if item.names~=nil then
					for _,ilist in pairs(item.names) do
						local obj= Zutil.deepcopy(item)
						obj.names=nil
						obj.name=ilist
						if root.itemDescriptorsMatch(stack[index], obj) then
							counts=counts+stack[index]["count"]
							table.insert(item2, obj)
							if item.count<=counts then	goto skip	end
						end
					end
				elseif root.itemDescriptorsMatch(stack[index], item) then
					counts=counts+stack[index]["count"]
					if item.count<=counts then	goto skip	end
				end
			end
			return false
		end
		::skip::
	end
	for _,item in pairs(items) do
		if type(item.damage)=="number" then
			Zitem.damage(item)
		elseif item.consume~=false then
			Zcontainer.consumeAt(item, self.input)
		end
	end
	for _,item in pairs(item2) do
		if type(item.damage)=="number" then
			Zitem.damage(item)
		elseif item.consume~=false then
			Zcontainer.consumeAt(item, self.input)
		end
	end
	prod=Zcontainer.treasure(prod)
	if delayKey(delay) then
		return prod
	end
	return Zcontainer.addItems(prod)
end

function delayKey(delay)
	if not(delay==nil or delay==0) then
		storage.wait=(storage.clock+delay)%self.clockMax
		return true
	end
	return false
end

function die()
	local poz=entity.position()
	if config.getParameter("multicraftAPI.killStorage", false) or (type(storage.wait)=="number" and storage.wait~=0) then
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
			for _,item in pairs(storage.overflow) do
			world.spawnItem(item.name, poz, item.count)
		end
		end
	else
		for _,item in pairs(storage.overflow) do
			world.spawnItem(item.name, poz, item.count)
		end
	end
end

function triggerReceive()
	storage.active=true
end