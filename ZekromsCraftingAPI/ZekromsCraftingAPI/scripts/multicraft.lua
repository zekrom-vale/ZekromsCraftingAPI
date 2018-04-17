require "/scripts/ZekromsContainerUtil.lua"
require "/scripts/ZekromsUtil.lua"
function init()
	if storage.clock==nil then
		storage.clock=0
	end
	self.input=config.getParameter("multicraftAPI.input", {1, size})
	self.output=config.getParameter("multicraftAPI.output", {1, size})
	self.recipes=root.assetJson(config.getParameter("multicraftAPI.recipefile"),{})
	self.clockMax=math.floor(config.getParameter("multicraftAPI.clockMax",10000))
	verify()
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
	if item==nil or type(item)~="number" or item%1~=0 or item>size or item<=0 then
		Zutil.API()
		sb.logWarn("Input/output array is not 2 elements for: "..Zutil.sbName()..".  Trying to compensate")
		return nil
	end
	return item
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
	end
end

function consumeItemsShaped(items, prod, stacks, delay) --In order
	for key,item in pairs(items) do
		local stack=stacks[key+self.input[1]-1]
		if stack==nil then	return false	end
		if not(item["name"]==stack["name"] and item["count"]<=stack["count"]) then
			return false
		end
	end
	for _,item in pairs(items) do
		Zcontainer.consumeAt(item, self.input)
	end
	prod=Zcontainer.treasure(prod)
	if not(delay==nil or delay==0) then
		storage.wait=(storage.clock+delay)%self.clockMax
		return prod
	end
	return Zcontainer.addItems(prod)
end

function consumeItems(items, prod, stack, delay) --No order
	for _,item in pairs(items) do
		if true then
			local counts=0
			for index=self.input[1],self.input[2] do
				if stack[index]~=nil and item.name==stack[index]["name"] then
					counts=counts+stack[index]["count"]
					if item.count<=counts then	goto skip	end
				end
			end
			return false --Must be last statement in a block
		end
		::skip::
	end
	for _,item in pairs(items) do
		Zcontainer.consumeAt(item, self.input)
	end
	prod=Zcontainer.treasure(prod)
	if not(delay==nil or delay==0) then
		storage.wait=(storage.clock+delay)%self.clockMax
		return prod
	end
	return Zcontainer.addItems(prod)
end

function die()
	local drop=config.getParameter("multicraftAPI.drop", "all")
	local poz=entity.position()
	if drop=="all" then
		for _,item in pairs(storage.overflow) do
			world.spawnItem(item.name, poz, item.count)
		end
	end
end