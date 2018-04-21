require "/scripts/ZekromsContainerUtil.lua"
require "/scripts/ZekromsUtil.lua"
require "/scripts/ZekromsItemUtil.lua"
require "/scripts/ZekromsVerify.lua"
function init()
	storage.clock=storage.clock or 0
	local array={1, world.containerSize(entity.id())}
	self=config.getParameter("multicraftAPI")
	self={
		input=self.input or array,
		output=self.output or array,
		recipes=root.assetJson(self.recipefile) or {},
		clockMax=self.clockMax or 10000,
		level=self.level or 1,
		init=true,
		killStorage=self.killStorage,
		drop=self.drop,
		trigger=getTrigger()
	}
	message.setHandler("triggerReceive", function(_, _, params)
		storage.active=true
	end)
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

function update(dt)
	local storage=storage
	if self.init then
		self.init=nil
		Zverify.verify()
	end
	if self.trigger==true and storage.active~=true then
		return
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
			if storage.overflow~=false then	goto updateEnd	end
		end
		storage.active=false
		::updateEnd::
	else
		storage.active=false
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
						obj.names,obj.name=nil,val
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
	local storage=storage
	local self=self
	local function drop(poz)
		for _,item in pairs(storage.overflow) do
			world.spawnItem(item.name, poz, item.count)
		end
	end
	local poz=entity.position()
	if self.killStorage or (type(storage.wait)=="number" and storage.wait~=0) then
		if self.drop=="none" or self.drop==0 then
			return
		elseif type(self.drop)=="number" then
			if self.drop>0 then
				for _,item in pairs(storage.overflow) do
					world.spawnItem(item.name, poz, math.ceil(item.count*self.drop))
				end
			else
				for _,item in pairs(storage.overflow) do
					world.spawnItem(item.name, poz, math.floor(item.count*-self.drop))
				end
			end
		else
			drop(poz)
		end
	else
		drop(poz)
	end
end