Zitem={}
function Zitem.damageAt(offset)
	local id=entity.id()
	local config=root.itemConfig(item.name).config
	item=world.containerItemAt(id, offset-1)
	item.parameters.durabilityHit=(item.parameters.durabilityHit or 0)+(config.durabilityPerUse or 1)
	if (config.durability or 100)<=item.parameters.durabilityHit then
		world.containerConsumeAt(id, offset-1, 1)
	else
		world.containerSwapItemsNoCombine(id, item, offset-1)
	end
end

function Zitem.damage(item)
	local id=entity.id()
	local stacks=world.containerItems(id)
	for offset=self.input[1],self.input[2] do
		local stack=stacks[offset]
		if root.itemDescriptorsMatch(stack, item) then
			local config=root.itemConfig(stack.name).config
			stack.parameters.durabilityHit=(stack.parameters.durabilityHit or 0)+(config.durabilityPerUse or 1)
			if (config.durability or 100)<=stack.parameters.durabilityHit then
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