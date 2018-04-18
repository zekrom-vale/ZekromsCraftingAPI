function update(dt)
	local now=world.containerItemAt(entity.id(), 0)
	if now==nil then
		if self.prev~=nil then
			self.prev=now
		end
	elseif prev==nil or self.prev.name~=now.name then
		object.say(sb.printJson(now))
		sb.logInfo(sb.printJson(now),1)
		sb.logInfo(sb.printJson(root.itemConfig(now),1))
		self.prev=now
	end
end