function trigger()
	world.sendEntityMessage(pane.containerEntityId(),"trigger")
end
function mode()
	world.sendEntityMessage(pane.containerEntityId(),"mode")
end