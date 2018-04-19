Zitem={}
--[[function Zitem.damageAt(offset)--Not up to date!
	local id, config=entity.id(), root.itemConfig(item.name).config
	item=world.containerItemAt(id, offset-1)
	item.parameters.durabilityHit=(item.parameters.durabilityHit or 0)+(config.durabilityPerUse or 1)
	if (config.durability or 200)<=item.parameters.durabilityHit then
		world.containerConsumeAt(id, offset-1, 1)
	else
		world.containerSwapItemsNoCombine(id, item, offset-1)
	end
end]]

function Zitem.damage(item)
	if item.names~=nil and item.name==nil then	return	end
	local id=entity.id()
	local config=root.itemConfig(item.name).config
	if item.damage>0 then
		local damage=math.ceil(item.damage*config.durabilityPerUse)
	else
		local damage=math.floor(-item.damage*config.durabilityPerUse)
	end
	for offset=self.input[1],self.input[2] do
		local stack=world.containerItems(id)[offset]
		if root.itemDescriptorsMatch(stack, item) then
			stack.parameters.durabilityHit=(stack.parameters.durabilityHit or 0)+(damage or 1)
			if (config.durability or 200)<=stack.parameters.durabilityHit then
				world.containerConsumeAt(id, offset-1, 1)
			else
				world.containerSwapItemsNoCombine(id, stack, offset-1)
			end
			return true
		end
	end
	return false
end
--/spawnitem copperpickaxe 1 '{"durabilityHit":210}'