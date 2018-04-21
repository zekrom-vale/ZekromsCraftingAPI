function trigger()
	world.sendEntityMessage(pane.containerEntityId(), "triggerReceive")
	--world.callScriptedEntity(pane.containerEntityId(), "triggerReceive")
end