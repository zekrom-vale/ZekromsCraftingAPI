require "/scripts/ZekromsContainerUtil.lua"
require "/scripts/ZekromsUtil.lua"
require "/scripts/ZekromsItemUtil.lua"
require "/scripts/ZekromsVerify.lua"
function init()
	local array={1, world.containerSize(entity.id())}
	self=config.getParameter("multicraftAPI")
	self={
		input=self.input or array,
		output=self.output or array,
		recipes=root.assetJson(self.recipefile) or {},
		level=self.level or 1,
		init=true,
		killStorage=self.killStorage,
		drop=self.drop
	}
end

function containerCallback()
	if self.init then
		self.init=nil
		Zverify.verify()
	end
	dropNotEqual()
	if taken() and storage.stuffed~=true then
		consume()
	end
	local storage=storage
	revereConsume()
	local stack=world.containerItems(entity.id())
	for _,value in pairs(self.recipes) do
		local stop
		if value.shaped then
			stop=checkShaped(value.input, value.output, stack)
		else
			stop=check(value.input, value.output, stack)
		end
		if stop then	break	end
	end
end

function taken()
	if storage.output==nil or next(storage.output)==nil then	return false	end
	local stacks=world.containerItems(entity.id())
	local storage=storage
	local i=1
	for o=self.output[1],self.output[2] do
		if not root.itemDescriptorsMatch(stacks[o], storage.output[i]) or storage.output[i].count>stacks[o].count then
			return true
		end
		i=i+1
	end
	return false
end

function dropNotEqual()
	if storage.output==nil or next(storage.output)==nil then	return	end
	local stacks=world.containerItems(entity.id())
	local storage=storage
	local i=1
	for o=self.output[1],self.output[2] do
		if not root.itemDescriptorsMatch(stacks[o], storage.output[i]) and stacks[o]~=nil then
			world.spawnItem(stacks[o].name, entity.position(), stacks[o].count)
			world.containerTakeAt(entity.id(),o-1)
		end
		i=i+1
	end
end

function consume()
	if storage.toConsume==nil then
		sb.logError("Consume failed at "..Zutil.sbName())
		return
	end
	for _,item in pairs(storage.toConsume) do
		if type(item.damage)=="number" then
			Zitem.damage(item)
		elseif item.consume~=false then
			Zcontainer.consumeAt(item, self.input)
		end
	end
	storage.toConsume=nil
	storage.output=nil
end

function checkShaped(items, prod, stacks)
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
	storage.toConsume=sb.jsonMerge(items,item2)
	storage.output=prod
	Zcontainer.addItems(prod)
	if next(Zcontainer.addItems(prod))~=nil then
		storage.stuffed=true
	else
		storage.stuffed=false
	end
	return true
end

function check(items, prod, stack)
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
	storage.toConsume=sb.jsonMerge(items,item2)
	storage.output=prod
	if next(Zcontainer.addItems(prod))~=nil then
		storage.stuffed=true
	else
		storage.stuffed=false
	end
	return true
end

function die()
	revereConsume()
end

function revereConsume()
	if storage.output==nil then	return false	end
	for _,item in pairs(storage.output) do
		Zcontainer.consumeAt(item, self.output)
	end
	storage.output=nil
end