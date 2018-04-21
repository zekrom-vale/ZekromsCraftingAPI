Zreceive={}
function Zreceive.trigger()
	message.setHandler("trigger", function(_, _, params)
		storage.active=true
	end)
	self.trigger=true
end

function Zreceive.mode()
	if type(self.modeMax)~="number" then
		Zutil.API()
		sb.logError("modeMax missing or NaN in "..Zutil.sbName())
		return
	end
	storage.mode=storage.mode or 1
	message.setHandler("mode", function(_, _, params)
		storage.mode=storage.mode+1
		if storage.mode>self.modeMax then	storage.mode=1	end
	end)
	
end

function Zreceive.get()
	local config=root.assetJson(config.getParameter("uiConfig"))
	if not Zutil.inTable(config.scripts,"/scripts/ZekTrigger.lua") then
		return false
	end
	local trigger=Zutil.inTable(config.scriptWidgetCallbacks, "trigger")
	local mode=Zutil.inTable(config.scriptWidgetCallbacks, "mode")
	if trigger and mode then	return "both"	end
	if trigger then	return "trigger"	end
	if mode then	return "mode"	end
	return nil
end