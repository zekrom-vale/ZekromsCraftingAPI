Zitem={}
--[[function Zitem.damageAt(offset)--Not up to date!
	local id,config=entity.id(),root.itemConfig(item.name).config
	item=world.containerItemAt(id,offset-1)
	item.parameters.durabilityHit=(item.parameters.durabilityHit or 0)+(config.durabilityPerUse or 1)
	if (config.durability or 200)<=item.parameters.durabilityHit then
		world.containerConsumeAt(id,offset-1,1)
	else
		world.containerSwapItemsNoCombine(id,item,offset-1)
	end
end]]

function Zitem.damage(item,range)
	range=range or self.input
	if item.names and not item.name then	return	end
	local id,config=entity.id(),root.itemConfig(item.name).config
	local damage=item.damage*config.durabilityPerUse
	if item.damage>0 then
		damage=math.ceil(damage)
	else
		damage=-math.floor(damage)
	end
	local stacks=world.containerItems(id)
	for offset=table.unpack(range)do
		local stack=stacks[offset]
		if root.itemDescriptorsMatch(stack,item)then
			stack.parameters.durabilityHit=(stack.parameters.durabilityHit or 0)+(damage or 1)
			if(config.durability or 200)<=stack.parameters.durabilityHit then
				world.containerConsumeAt(id,offset-1,1)
			else
				world.containerSwapItemsNoCombine(id,stack,offset-1)
			end
			return true
		end
	end
	return false
end
--/spawnitem copperpickaxe 1 '{"durabilityHit":210}'