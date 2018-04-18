Zitem={}
function Zitem.damageAt(offset)
	local config=root.itemConfig(item.name).config
	item=world.containerItemAt(entity.id(), offset-1)
	item.parameters.durabilityHit=(item.parameters.durabilityHit or 0)+(config.durabilityPerUse or 1)
	if (config.durability or 100)<=item.parameters.durabilityHit then
		world.containerConsumeAt(entity.id(), offset-1, 1)
	else
		world.containerSwapItemsNoCombine(entity.id(), item, offset-1)
	end
end

function Zitem.damage(item)
	sb.logInfo("Zitem.damage")
	local stacks=world.containerItems(entity.id())
	for offset,stack in pairs(stack) do
		sb.logInfo(tostring(offset))
		sb.logInfo(stack.name)
		if item.name==stack.name then
			sb.logInfo("Match")
			local config=root.itemConfig(item.name).config
			stack.parameters.durabilityHit=(stack.parameters.durabilityHit or 0)+(config.durabilityPerUse or 1)
			if (config.durability or 100)<=stack.parameters.durabilityHit then
				world.containerConsumeAt(entity.id(), offset-1, 1)
			else
				world.containerSwapItemsNoCombine(entity.id(), stack, offset-1)
			end
			return true
		end
	end
	return false
end
--/spawnitem copperpickaxe 1 '{"durabilityHit":210}'